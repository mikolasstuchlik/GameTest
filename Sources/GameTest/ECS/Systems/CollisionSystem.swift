import NoobECS
import NoobECSStores

protocol CollisionSystemDelegate: AnyObject {
    func notifyCollisionOf(firstEntity: Entity, secondEntity: Entity, at time: UInt32)
}

final class AABBCollisionSystem: SDLSystem {
    private enum CollisionType {
        case none, notify, collide, collideNotify

        init(_ lhs: BoxObjectComponent, _ rhs: BoxObjectComponent) {
            switch (
                (lhs.categoryBitmask & rhs.collisionBitmask) > 0 || (rhs.categoryBitmask & lhs.collisionBitmask) > 0,
                (lhs.categoryBitmask & rhs.notificationBitmask ) > 0 || (rhs.categoryBitmask & lhs.notificationBitmask) > 0
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
            for other in immovable where currentStore.buffer[other] != nil {
                checkAndResolve(i, other, secondMovable: false, at: context.currentTime)
            }

            guard movable.contains(i + 1) else {
                continue
            }

            for other in (i + 1)..<movable.upperBound where currentStore.buffer[other] != nil {
                checkAndResolve(i, other, secondMovable: true, at: context.currentTime)
            }
        }
    }

    private func getCollision(_ lIndex: Int, _ rIndex: Int) -> CollisionType {
        let collisionType = CollisionType(currentStore.buffer[lIndex]!.value, currentStore.buffer[rIndex]!.value)

        if 
            collisionType == .none
            || !Rect(
                center: currentStore.buffer[lIndex]!.value.positionCenter, 
                radius: currentStore.buffer[lIndex]!.value.squareRadius
            ).intersects(
                with: Rect(
                    center: currentStore.buffer[rIndex]!.value.positionCenter, 
                    radius: currentStore.buffer[rIndex]!.value.squareRadius
                )
            )
        {
            return .none
        }

        return collisionType
    }

    private func checkAndResolve(_ lIndex: Int, _ rIndex: Int, secondMovable: Bool, at time: UInt32) {
        switch getCollision(lIndex, rIndex) {
        case .notify:
            delegate?.notifyCollisionOf(
                firstEntity: currentStore.buffer[lIndex]!.unownedEntity, 
                secondEntity: currentStore.buffer[rIndex]!.unownedEntity,
                at: time
            )
        case .collide where secondMovable:
            resolveCollision(movableIndex: lIndex, secondMovableIndex: rIndex)
        case .collide:
            resolveCollision(movableIndex: lIndex, immovableIndex: rIndex)
        case .collideNotify:
            delegate?.notifyCollisionOf(
                firstEntity: currentStore.buffer[lIndex]!.unownedEntity, 
                secondEntity: currentStore.buffer[rIndex]!.unownedEntity,
                at: time
            )
            resolveCollision(movableIndex: lIndex, secondMovableIndex: rIndex)
        case .collideNotify where secondMovable:
            delegate?.notifyCollisionOf(
                firstEntity: currentStore.buffer[lIndex]!.unownedEntity, 
                secondEntity: currentStore.buffer[rIndex]!.unownedEntity,
                at: time
            )
            resolveCollision(movableIndex: lIndex, immovableIndex: rIndex)
        case .none: return
        }
        reportIntrospection(first: lIndex, second: rIndex)
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
        // guard !collidedBeforeThisFrame(movableIndex: first, immovableIndex: second) else {
        //     return
        // }

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

    // private func collidedBeforeThisFrame(movableIndex first: Int, immovableIndex second: Int) -> Bool {
    //     let movable = pool.storage(for: BoxObjectComponent.self).buffer[first]!.value
    //     let immovable = pool.storage(for: BoxObjectComponent.self).buffer[second]!.value

    //     return determineCollision(
    //         lCenter: movable.positionCenter - movable.frameMovementVector, 
    //         lRadius: movable.squareRadius, 
    //         rCenter: immovable.positionCenter, 
    //         rRadius: immovable.squareRadius
    //     )
    // }

    private func reportIntrospection(first index: Int, second sIndex: Int) {
        _ = currentStore.buffer[index]!.unownedEntity.access(component: IntrospectionComponent.self) { comp in
            comp.frameCollidedWith.insert(currentStore.buffer[sIndex]!.unownedEntity)
        }

        _ = currentStore.buffer[sIndex]!.unownedEntity.access(component: IntrospectionComponent.self) { comp in
            comp.frameCollidedWith.insert(currentStore.buffer[index]!.unownedEntity)
        }
    }
}
