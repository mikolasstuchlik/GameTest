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
        case .none: return
        }
        reportIntrospection(first: index, second: sIndex)
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

        let collisionVector = 
            movable.buffer[first]!.value.positionCenter
            → movable.buffer[second]!.value.positionCenter
        let collisionOrientation = collisionVector.degreees

        switch collisionOrientation {
        case 316...361, 0..<46, 136.0..<226.0:
            let horizontalSpace = 
                (
                    movable.buffer[first]!.value.squareRadius.width
                    + movable.buffer[second]!.value.squareRadius.width
                    - abs(collisionVector.x)
                ) / 2

            let orientation: Float = (136.0..<226.0).contains(collisionOrientation)
                ? 1.0
                : -1.0

            movable.buffer[first]!.value.frameMovementVector.x += horizontalSpace * orientation
            movable.buffer[first]!.value.positionCenter.x += horizontalSpace * orientation

            movable.buffer[second]!.value.frameMovementVector.x += horizontalSpace * -orientation
            movable.buffer[second]!.value.positionCenter.x += horizontalSpace * -orientation
        case 46.0..<136.0, 226.0..<316.0:
            let verticalSpace = 
                (
                    movable.buffer[first]!.value.squareRadius.height
                    + movable.buffer[second]!.value.squareRadius.height
                    - abs(collisionVector.y)
                ) / 2
            
            let orientation: Float = (226.0..<316.0).contains(collisionOrientation)
                ? 1.0
                : -1.0

            movable.buffer[first]!.value.frameMovementVector.y += verticalSpace * orientation 
            movable.buffer[first]!.value.positionCenter.y += verticalSpace * orientation

            movable.buffer[second]!.value.frameMovementVector.y += verticalSpace * -orientation
            movable.buffer[second]!.value.positionCenter.y += verticalSpace * -orientation
        default:
            fatalError("invalid angle")
        }
    }

    private func resolveCollision(movableIndex first: Int, immovableIndex second: Int) { 
        let movable = pool.storage(for: BoxObjectComponent.self)
        let immovable = pool.storage(for: BoxObjectComponent.self).buffer[second]!.value


        let collisionVector = 
            movable.buffer[first]!.value.positionCenter
            → immovable.positionCenter
        let collisionOrientation = collisionVector.degreees

        switch collisionOrientation {
        case 316...361, 0..<46, 136.0..<226.0:
            let horizontalSpace = 
                movable.buffer[first]!.value.squareRadius.width
                + immovable.squareRadius.width
                - abs(collisionVector.x)

            let orientation: Float = (136.0..<226.0).contains(collisionOrientation)
                ? 1.0
                : -1.0

            movable.buffer[first]!.value.frameMovementVector.x += horizontalSpace * orientation
            movable.buffer[first]!.value.positionCenter.x += horizontalSpace * orientation
        case 46.0..<136.0, 226.0..<316.0:
            let verticalSpace = 
                movable.buffer[first]!.value.squareRadius.height
                + immovable.squareRadius.height
                - abs(collisionVector.y)
            
            let orientation: Float = (226.0..<316.0).contains(collisionOrientation)
                ? 1.0
                : -1.0

            movable.buffer[first]!.value.frameMovementVector.y += verticalSpace * orientation 
            movable.buffer[first]!.value.positionCenter.y += verticalSpace * orientation
        default:
            fatalError("invalid angle")
        }
    }

    private func reportIntrospection(first index: Int, second sIndex: Int) {
        _ = currentStore.buffer[index]!.unownedEntity.access(component: IntrospectionComponent.self) { comp in
            comp.frameCollidedWith.insert(currentStore.buffer[sIndex]!.unownedEntity)
        }

        _ = currentStore.buffer[sIndex]!.unownedEntity.access(component: IntrospectionComponent.self) { comp in
            comp.frameCollidedWith.insert(currentStore.buffer[index]!.unownedEntity)
        }
    }
}
