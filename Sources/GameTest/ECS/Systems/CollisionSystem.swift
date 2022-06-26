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

    // Resolution using distance has obvious issues. We might use some other value to determine priority, such as intersection
    // area, but we assume the system operates on (an aproximation of) tilemap.
    private struct ResolutionCandidate {
        let lIndex: Int
        let rIndex: Int
        let resolutionRatio: Float
        let distance: Float
    }

    weak var delegate: CollisionSystemDelegate?

    private var currentStore: BoxObjectComponent.Store!
    private var resolutionQueue: [ResolutionCandidate] = []

    override func update(with context: UpdateContext) throws {
        currentStore = pool.storage(for: BoxObjectComponent.self)
        defer { currentStore = nil }

        guard let movable = currentStore.category[.movable] else {
            return
        }
        let immovable = currentStore.category[.immovable] ?? 0..<1

        for i in movable where currentStore.buffer[i] != nil {
            for other in immovable where currentStore.buffer[other] != nil {
                checkAndNotify(i, other, secondMovable: false, at: context.currentTime)
            }

            guard movable.contains(i + 1) else {
                continue
            }

            for other in (i + 1)..<movable.upperBound where currentStore.buffer[other] != nil {
                checkAndNotify(i, other, secondMovable: true, at: context.currentTime)
            }

            resolve()
        }
    }

    private func collides(_ lIndex: Int, _ rIndex: Int) -> Bool {
        Rect(
            center: currentStore.buffer[lIndex]!.value.positionCenter, 
            radius: currentStore.buffer[lIndex]!.value.squareRadius
        ).intersects(
            with: Rect(
                center: currentStore.buffer[rIndex]!.value.positionCenter, 
                radius: currentStore.buffer[rIndex]!.value.squareRadius
            )
        )
    }

    private func getCollision(_ lIndex: Int, _ rIndex: Int) -> CollisionType {
        let collisionType = CollisionType(currentStore.buffer[lIndex]!.value, currentStore.buffer[rIndex]!.value)

        if 
            collisionType == .none
            || !collides(rIndex, lIndex)
        {
            return .none
        }

        return collisionType
    }

    private func checkAndNotify(_ lIndex: Int, _ rIndex: Int, secondMovable: Bool, at time: UInt32) {
        let distance = currentStore.buffer[lIndex]!.value.positionCenter.distance(
            to: currentStore.buffer[rIndex]!.value.positionCenter
        )

        switch getCollision(lIndex, rIndex) {
        case .notify:
            delegate?.notifyCollisionOf(
                firstEntity: currentStore.buffer[lIndex]!.unownedEntity, 
                secondEntity: currentStore.buffer[rIndex]!.unownedEntity,
                at: time
            )
        case .collide where secondMovable:
            resolutionQueue.append(
                ResolutionCandidate(lIndex: lIndex, rIndex: rIndex, resolutionRatio: 0.5, distance: distance)
            )
        case .collide:
            resolutionQueue.append(
                ResolutionCandidate(lIndex: lIndex, rIndex: rIndex, resolutionRatio: 0.0, distance: distance)
            )
        case .collideNotify:
            delegate?.notifyCollisionOf(
                firstEntity: currentStore.buffer[lIndex]!.unownedEntity, 
                secondEntity: currentStore.buffer[rIndex]!.unownedEntity,
                at: time
            )
            resolutionQueue.append(
                ResolutionCandidate(lIndex: lIndex, rIndex: rIndex, resolutionRatio: 0.0, distance: distance)
            )
        case .collideNotify where secondMovable:
            delegate?.notifyCollisionOf(
                firstEntity: currentStore.buffer[lIndex]!.unownedEntity, 
                secondEntity: currentStore.buffer[rIndex]!.unownedEntity,
                at: time
            )
            resolutionQueue.append(
                ResolutionCandidate(lIndex: lIndex, rIndex: rIndex, resolutionRatio: 0.5, distance: distance)
            )
        case .none: return
        }
        reportIntrospection(first: lIndex, second: rIndex)
    }

    // first entity is always movable
    private func resolveCollision(_ lIndex: Int, _ rIndex: Int, distributionRatio: Float) { 
        assert(distributionRatio >= 0.0 && distributionRatio <= 1.0, "Ratio is not in interval [0.0, 1.0]")

        let movable = pool.storage(for: BoxObjectComponent.self)

        let collisionVector = 
            movable.buffer[lIndex]!.value.positionCenter
            → movable.buffer[rIndex]!.value.positionCenter
        let collisionOrientation = collisionVector.degreees

        switch collisionOrientation {
        case 316...361, 0..<46, 136.0..<226.0:
            let lHorizontalSpace = 
                (
                    movable.buffer[lIndex]!.value.squareRadius.width
                    + movable.buffer[rIndex]!.value.squareRadius.width
                    - abs(collisionVector.x)
                ) * (1.0 - distributionRatio)
            
            let rHorizontalSpace = 
                (
                    movable.buffer[lIndex]!.value.squareRadius.width
                    + movable.buffer[rIndex]!.value.squareRadius.width
                    - abs(collisionVector.x)
                ) * distributionRatio

            let orientation: Float = (136.0..<226.0).contains(collisionOrientation)
                ? 1.0
                : -1.0

            movable.buffer[lIndex]!.value.frameMovementVector.x += lHorizontalSpace * orientation
            movable.buffer[lIndex]!.value.positionCenter.x += lHorizontalSpace * orientation

            movable.buffer[rIndex]!.value.frameMovementVector.x += rHorizontalSpace * -orientation
            movable.buffer[rIndex]!.value.positionCenter.x += rHorizontalSpace * -orientation
        case 46.0..<136.0, 226.0..<316.0:
            let lVerticalSpace = 
                (
                    movable.buffer[lIndex]!.value.squareRadius.height
                    + movable.buffer[rIndex]!.value.squareRadius.height
                    - abs(collisionVector.y)
                ) * ( 1.0 - distributionRatio )
            let rVerticalSpace = 
                (
                    movable.buffer[lIndex]!.value.squareRadius.height
                    + movable.buffer[rIndex]!.value.squareRadius.height
                    - abs(collisionVector.y)
                ) * distributionRatio
            
            let orientation: Float = (226.0..<316.0).contains(collisionOrientation)
                ? 1.0
                : -1.0

            movable.buffer[lIndex]!.value.frameMovementVector.y += lVerticalSpace * orientation 
            movable.buffer[lIndex]!.value.positionCenter.y += lVerticalSpace * orientation

            movable.buffer[rIndex]!.value.frameMovementVector.y += rVerticalSpace * -orientation
            movable.buffer[rIndex]!.value.positionCenter.y += rVerticalSpace * -orientation
        default:
            fatalError("invalid angle")
        }
    }

    private func resolve() {
        resolutionQueue.sorted { $0.distance < $1.distance }.forEach { candidate in
            guard collides(candidate.lIndex, candidate.rIndex) else { return }
            resolveCollision(candidate.lIndex, candidate.rIndex, distributionRatio: candidate.resolutionRatio)
        }

        resolutionQueue.removeAll()
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
