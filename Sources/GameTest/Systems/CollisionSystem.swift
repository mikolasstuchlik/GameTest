protocol CollisionSystemDelegate: AnyObject {
    func notifyCollisionOf(firstEntity: Entity, secondEntity: Entity)
}

final class AABBCollisionSystem: System {
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

    func update(with context: UpdateContext) throws {
        for i in 0..<MovableObjectComponent.storage.count where MovableObjectComponent.storage[i].isValid {
            for other in 0..<ImmovableObjectComponent.storage.count where ImmovableObjectComponent.storage[i].isValid {
                let collisionType = CollisionType(
                    lCategory: MovableObjectComponent.storage[i].categoryBitmask, 
                    lCollision: MovableObjectComponent.storage[i].collisionBitmask, 
                    lNotify: MovableObjectComponent.storage[i].notificationBitmask, 
                    rCategory: ImmovableObjectComponent.storage[other].categoryBitmask, 
                    rCollision: 0, 
                    rNotify: 0
                )

                if 
                    collisionType == .none
                    || determineCollision(
                        lCenter: MovableObjectComponent.storage[i].positionCenter, 
                        lRadius: MovableObjectComponent.storage[i].squareRadius, 
                        rCenter: ImmovableObjectComponent.storage[other].positionCenter, 
                        rRadius: ImmovableObjectComponent.storage[other].squareRadius
                    ) == false
                {
                    continue
                }

                switch collisionType {
                case .notify:
                    delegate?.notifyCollisionOf(
                        firstEntity: MovableObjectComponent.storage[i].entity!, 
                        secondEntity: ImmovableObjectComponent.storage[other].entity!
                    )
                case .collide:
                    resolveCollision(movableIndex: i, immovableIndex: other)
                case .collideNotify:
                    delegate?.notifyCollisionOf(
                        firstEntity: MovableObjectComponent.storage[i].entity!, 
                        secondEntity: ImmovableObjectComponent.storage[other].entity!
                    )
                    resolveCollision(movableIndex: i, immovableIndex: other)
                case .none: break
                }
            }

            guard i < MovableObjectComponent.storage.count - 1 else {
                continue
            }

            for other in (i + 1)..<MovableObjectComponent.storage.count where MovableObjectComponent.storage[other].isValid {
                let collisionType = CollisionType(
                    lCategory: MovableObjectComponent.storage[i].categoryBitmask, 
                    lCollision: MovableObjectComponent.storage[i].collisionBitmask, 
                    lNotify: MovableObjectComponent.storage[i].notificationBitmask, 
                    rCategory: MovableObjectComponent.storage[other].categoryBitmask, 
                    rCollision: 0, 
                    rNotify: 0
                )

                if 
                    collisionType == .none
                    || determineCollision(
                        lCenter: MovableObjectComponent.storage[i].positionCenter, 
                        lRadius: MovableObjectComponent.storage[i].squareRadius, 
                        rCenter: MovableObjectComponent.storage[other].positionCenter, 
                        rRadius: MovableObjectComponent.storage[other].squareRadius
                    ) == false
                {
                    continue
                }

                switch collisionType {
                case .notify:
                    delegate?.notifyCollisionOf(
                        firstEntity: MovableObjectComponent.storage[i].entity!, 
                        secondEntity: MovableObjectComponent.storage[other].entity!
                    )
                case .collide:
                    resolveCollision(movableIndex: i, secondMovableIndex: other)
                case .collideNotify:
                    delegate?.notifyCollisionOf(
                        firstEntity: MovableObjectComponent.storage[i].entity!, 
                        secondEntity: MovableObjectComponent.storage[other].entity!
                    )
                    resolveCollision(movableIndex: i, secondMovableIndex: other)
                case .none: break
                }
            }

        }
    }

    func render(with context: RenderContext) throws { }

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
    private func resolveCollision(movableIndex: Int, secondMovableIndex: Int) { 
        
    }

    private func resolveCollision(movableIndex: Int, immovableIndex: Int) { 
        
    }
}