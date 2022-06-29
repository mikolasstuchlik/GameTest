import NoobECS
import NoobECSStores

protocol CollisionSystemDelegate: AnyObject {
    func notifyCollisionOf(in system: AABBCollisionSystem, firstEntity: Entity, secondEntity: Entity, at time: UInt32)
    func reaffirmExceptions(in system: AABBCollisionSystem, for entity: Entity, exceptionComponent: inout Set<ObjectIdentifier>)
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

        guard let movable = currentStore.category[.movable] else {
            return
        }
        let immovable = currentStore.category[.immovable] ?? 0..<1

        for i in movable where currentStore.buffer[i] != nil {
            for other in immovable where currentStore.buffer[other] != nil {
                checkAndNotify(i, other, secondMovable: false, at: context.currentTime)
            }

            guard movable.contains(i + 1) else {
                resolve()
                continue
            }

            for other in (i + 1)..<movable.upperBound where currentStore.buffer[other] != nil {
                checkAndNotify(i, other, secondMovable: true, at: context.currentTime)
            }

            resolve()
        }

        let exceptionStore = pool.storage(for: CollisionExceptionComponent.self)
        for i in 0..<exceptionStore.buffer.count where exceptionStore.buffer[i] != nil {
            delegate?.reaffirmExceptions(
                in: self,
                for: exceptionStore.buffer[i]!.unownedEntity, 
                exceptionComponent: &exceptionStore.buffer[i]!.value.collisionException
            )
            if exceptionStore.buffer[i]!.value.collisionException.isEmpty {
                exceptionStore.buffer[i]!.unownedEntity.destroy(component: CollisionExceptionComponent.self)
            }
        }
    }

    private func collides(_ lIndex: Int, _ rIndex: Int) -> Bool {
        CenterRect(
            center: currentStore.buffer[lIndex]!.value.positionCenter, 
            range: currentStore.buffer[lIndex]!.value.squareRadius
        ).intersects(
            with: CenterRect(
                center: currentStore.buffer[rIndex]!.value.positionCenter, 
                range: currentStore.buffer[rIndex]!.value.squareRadius
            )
        )
    }

    private func exceptionAppliesFor(_ lIndex: Int, _ rIndex: Int) -> Bool {
        let lEntity = currentStore.buffer[lIndex]!.unownedEntity
        let rEntity = currentStore.buffer[rIndex]!.unownedEntity

        let lException = lEntity.access(component: CollisionExceptionComponent.self) { component in
            component.collisionException.contains(ObjectIdentifier(rEntity))
        }
        let rException = rEntity.access(component: CollisionExceptionComponent.self) { component in
            component.collisionException.contains(ObjectIdentifier(lEntity))
        }

        return lException == true || rException == true
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
                in: self,
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
                in: self,
                firstEntity: currentStore.buffer[lIndex]!.unownedEntity, 
                secondEntity: currentStore.buffer[rIndex]!.unownedEntity,
                at: time
            )
            resolutionQueue.append(
                ResolutionCandidate(lIndex: lIndex, rIndex: rIndex, resolutionRatio: 0.0, distance: distance)
            )
        case .collideNotify where secondMovable:
            delegate?.notifyCollisionOf(
                in: self,
                firstEntity: currentStore.buffer[lIndex]!.unownedEntity, 
                secondEntity: currentStore.buffer[rIndex]!.unownedEntity,
                at: time
            )
            resolutionQueue.append(
                ResolutionCandidate(lIndex: lIndex, rIndex: rIndex, resolutionRatio: 0.5, distance: distance)
            )
        case .none: return
        }
        reportIntrospection(lIndex, rIndex)
    }

    private func resolveCollision(_ lIndex: Int, _ rIndex: Int, distributionRatio: Float) { 
        assert(distributionRatio >= 0.0 && distributionRatio <= 1.0, "Ratio is not in interval [0.0, 1.0]")

        let collisionVector = 
            currentStore.buffer[lIndex]!.value.positionCenter
            → currentStore.buffer[rIndex]!.value.positionCenter
        let collisionOrientation = collisionVector.degreees

        switch collisionOrientation {
        case 316...361, 0..<46, 136.0..<226.0:
            let horizontalSpace = 
                (
                    currentStore.buffer[lIndex]!.value.squareRadius.width
                    + currentStore.buffer[rIndex]!.value.squareRadius.width
                    - abs(collisionVector.x)
                )

            let orientation: Float = (136.0..<226.0).contains(collisionOrientation)
                ? 1.0
                : -1.0

            currentStore.buffer[lIndex]!.value.frameMovementVector.x += horizontalSpace * (1 - distributionRatio) * orientation
            currentStore.buffer[lIndex]!.value.positionCenter.x += horizontalSpace * (1 - distributionRatio) * orientation

            currentStore.buffer[rIndex]!.value.frameMovementVector.x += horizontalSpace * distributionRatio * -orientation
            currentStore.buffer[rIndex]!.value.positionCenter.x += horizontalSpace * distributionRatio * -orientation
        case 46.0..<136.0, 226.0..<316.0:
            let verticalSpace = 
                (
                    currentStore.buffer[lIndex]!.value.squareRadius.height
                    + currentStore.buffer[rIndex]!.value.squareRadius.height
                    - abs(collisionVector.y)
                )

            let orientation: Float = (226.0..<316.0).contains(collisionOrientation)
                ? 1.0
                : -1.0

            currentStore.buffer[lIndex]!.value.frameMovementVector.y += verticalSpace * (1.0 - distributionRatio) * orientation 
            currentStore.buffer[lIndex]!.value.positionCenter.y += verticalSpace * (1.0 - distributionRatio) * orientation

            currentStore.buffer[rIndex]!.value.frameMovementVector.y += verticalSpace * distributionRatio * -orientation
            currentStore.buffer[rIndex]!.value.positionCenter.y += verticalSpace * distributionRatio * -orientation
        default:
            fatalError("invalid angle")
        }
    }

    private func resolve() {
        resolutionQueue.sorted { $0.distance < $1.distance }.forEach { candidate in
            guard collides(candidate.lIndex, candidate.rIndex) else { return }
            guard !exceptionAppliesFor(candidate.lIndex, candidate.rIndex) else { return }
            resolveCollision(candidate.lIndex, candidate.rIndex, distributionRatio: candidate.resolutionRatio)
        }

        resolutionQueue.removeAll()
    }

    private func reportIntrospection(_ lIndex: Int, _ rIndex: Int) {
        guard currentStore.buffer[lIndex] != nil, currentStore.buffer[rIndex] != nil else {
            return
        }
        _ = currentStore.buffer[lIndex]!.unownedEntity.access(component: IntrospectionComponent.self) { comp in
            comp.frameCollidedWith.insert(currentStore.buffer[rIndex]!.unownedEntity)
        }

        _ = currentStore.buffer[rIndex]!.unownedEntity.access(component: IntrospectionComponent.self) { comp in
            comp.frameCollidedWith.insert(currentStore.buffer[lIndex]!.unownedEntity)
        }
    }
}

extension AABBCollisionSystem {
    func collisions(for entity: Entity) -> [Entity] {
        currentStore = pool.storage(for: BoxObjectComponent.self)

        guard let reference = entity.componentReferences.first(where: { $0.type == BoxObjectComponent.self }) else {
            return []
        }

        var result = [Entity]()
        let index = reference.identifier as! BoxObjectComponent.Store.ComponentIdentifier
        for i in 0..<currentStore.buffer.count where currentStore.buffer[i] != nil {
            guard i != index else { continue }
            switch getCollision(index, i) {
            case .collide, .collideNotify:
                result.append(currentStore.buffer[i]!.unownedEntity)
            default: break
            }
        }

        return result
    }

    func entities<R: Rect>(in rect: R) -> [Entity] where R.Number == Float {
        currentStore = pool.storage(for: BoxObjectComponent.self)

        var result = [Entity]()
        for i in 0..<currentStore.buffer.count where currentStore.buffer[i] != nil {
            if 
                rect.intersects(with: CenterRect(
                    center: currentStore.buffer[i]!.value.positionCenter, 
                    range: currentStore.buffer[i]!.value.squareRadius
                ))
            {
                result.append(currentStore.buffer[i]!.unownedEntity)
            }
        }

        return result
    }
}