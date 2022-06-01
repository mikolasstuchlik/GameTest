import NoobECS
import NoobECSStores

protocol CollisionSystemDelegate: AnyObject {
    func notifyCollisionOf(firstEntity: Entity, secondEntity: Entity)
}

final class AABBCollisionSystem: SDLSystem {
    private enum CollisionType {
        case none, notify, collide, collideNotify

        init(
            lCategory: UInt32, 
            lCollision: UInt32, 
            lNotify: UInt32,
            rCategory: UInt32,
            rCollision: UInt32,
            rNotify: UInt32
        ) {
            switch (
                (lCategory & rCollision) > 0 || (rCategory & lCollision) > 0,
                (lCategory & rNotify ) > 0 || (rCategory & lNotify) > 0
            ) {
            case (false, false):
                self = .none
            case (true, true):
                self = .collideNotify
            case (true, false):
                self = .collide
            case (false, true):
                self = .notify
            }
        }
    }

    weak var delegate: CollisionSystemDelegate?

    private var currentStore: BoxObjectComponent.Store!
    override func update(with context: UpdateContext) throws {
        currentStore = pool.storage(for: BoxObjectComponent.self)
        defer { currentStore = nil }

        guard let movable = currentStore.category[.movable] else {
            return
        }
        let immovable = currentStore.category[.immovable] ?? 0..<1

        for i in movable where currentStore.buffer[i] != nil {
            for other in immovable where currentStore.buffer[i] != nil {
                checkAndResolve(first: i, second: other, secondMovable: false)
            }

            guard movable.contains(i + 1) else {
                continue
            }

            for other in (i + 1)..<movable.upperBound where currentStore.buffer[other] != nil {
                checkAndResolve(first: i, second: other, secondMovable: true)
            }

        }
    }

    private func getCollision(first index: Int, second sIndex: Int) -> CollisionType {
        let collisionType = CollisionType(
            lCategory: currentStore.buffer[index]!.value.categoryBitmask, 
            lCollision: currentStore.buffer[index]!.value.collisionBitmask, 
            lNotify: currentStore.buffer[index]!.value.notificationBitmask, 
            rCategory: currentStore.buffer[sIndex]!.value.categoryBitmask, 
            rCollision: currentStore.buffer[sIndex]!.value.collisionBitmask,
            rNotify: currentStore.buffer[sIndex]!.value.notificationBitmask
        )

        if 
            collisionType == .none
            || determineCollision(
                lCenter: currentStore.buffer[index]!.value.positionCenter, 
                lRadius: currentStore.buffer[index]!.value.squareRadius, 
                rCenter: currentStore.buffer[sIndex]!.value.positionCenter, 
                rRadius: currentStore.buffer[sIndex]!.value.squareRadius
            ) == false
        {
            return .none
        }

        return collisionType
    }

    private func checkAndResolve(first index: Int, second sIndex: Int, secondMovable: Bool) {
        switch getCollision(first: index, second: sIndex) {
        case .notify:
            delegate?.notifyCollisionOf(
                firstEntity: currentStore.buffer[index]!.unownedEntity, 
                secondEntity: currentStore.buffer[sIndex]!.unownedEntity
            )
        case .collide where secondMovable:
            resolveCollision(movableIndex: index, secondMovableIndex: sIndex)
        case .collide:
            resolveCollision(movableIndex: index, immovableIndex: sIndex)
        case .collideNotify:
            delegate?.notifyCollisionOf(
                firstEntity: currentStore.buffer[index]!.unownedEntity, 
                secondEntity: currentStore.buffer[sIndex]!.unownedEntity
            )
            resolveCollision(movableIndex: index, secondMovableIndex: sIndex)
        case .collideNotify where secondMovable:
            delegate?.notifyCollisionOf(
                firstEntity: currentStore.buffer[index]!.unownedEntity, 
                secondEntity: currentStore.buffer[sIndex]!.unownedEntity
            )
            resolveCollision(movableIndex: index, immovableIndex: sIndex)
        case .none: break
        }
    }

    private func determineCollision(
        lCenter: Point<Float>, 
        lRadius: Size<Float>,
        rCenter: Point<Float>,
        rRadius: Size<Float>
    ) -> Bool {
           lCenter.x - lRadius.width  < rCenter.x + rRadius.width
        && lCenter.x + lRadius.width  > rCenter.x - rRadius.width
        && lCenter.y - lRadius.height < rCenter.y + rRadius.height
        && lCenter.y + lRadius.height > rCenter.y - rRadius.height
    }

    // first entity is always movable
    private func resolveCollision(movableIndex first: Int, secondMovableIndex second: Int) { 
        let movable = pool.storage(for: BoxObjectComponent.self)
        print("Collision \(movable.buffer[first]!.unownedEntity.developerLabel ?? String(describing: movable.buffer[first]!.unownedEntity)) and \(movable.buffer[second]!.unownedEntity.developerLabel ?? String(describing: movable.buffer[second]!.unownedEntity)): 2 movable not implemented")
    }

    private func resolveCollision(movableIndex: Int, immovableIndex: Int) { 
        let movable = pool.storage(for: BoxObjectComponent.self)
        let immovable = pool.storage(for: BoxObjectComponent.self).buffer[immovableIndex]!.value

        let movementLine = Line(
            origin: movable.buffer[movableIndex]!.value.positionCenter - movable.buffer[movableIndex]!.value.frameMovementVector,
            vector: movable.buffer[movableIndex]!.value.frameMovementVector
        )
        let immovableBoundingLines = Rect(
            center: immovable.positionCenter,
            size: 
                immovable.squareRadius * 2 
                + movable.buffer[movableIndex]!.value.squareRadius * 2
        ).lines

        let intersection = immovableBoundingLines
            .map(movementLine.intersection(with:))
            .enumerated()
            .filter { (0...1.0).contains($1) }
            .min { abs($0.element) < abs($1.element) }

        guard let (side, intersection) = intersection else {
            assertionFailure("Collision resolution didn't find collision")
            return
        }

        let newPosition = movementLine.origin + movementLine.vector * intersection

        if side % 2 == 0 {
            movable.buffer[movableIndex]!.value.positionCenter.y = newPosition.y
        } else {
            movable.buffer[movableIndex]!.value.positionCenter.x = newPosition.x
        }
    }
}
