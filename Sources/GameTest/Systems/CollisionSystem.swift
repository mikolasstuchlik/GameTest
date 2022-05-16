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

    unowned(unsafe) let pool: Pool
    weak var delegate: CollisionSystemDelegate?

    init(pool: Pool) {
        self.pool = pool
    }

    func update(with context: UpdateContext) throws {
        let movable = pool.storage(for: MovableObjectComponent.self)
        let immovable = pool.storage(for: ImmovableObjectComponent.self)

        for i in 0..<movable.buffer.count where movable.buffer[i].isValid {
            for other in 0..<immovable.buffer.count where immovable.buffer[i].isValid {
                let collisionType = CollisionType(
                    lCategory: movable.buffer[i].categoryBitmask, 
                    lCollision: movable.buffer[i].collisionBitmask, 
                    lNotify: movable.buffer[i].notificationBitmask, 
                    rCategory: immovable.buffer[other].categoryBitmask, 
                    rCollision: 0, 
                    rNotify: 0
                )

                if 
                    collisionType == .none
                    || determineCollision(
                        lCenter: movable.buffer[i].positionCenter, 
                        lRadius: movable.buffer[i].squareRadius, 
                        rCenter: immovable.buffer[other].positionCenter, 
                        rRadius: immovable.buffer[other].squareRadius
                    ) == false
                {
                    continue
                }

                switch collisionType {
                case .notify:
                    delegate?.notifyCollisionOf(
                        firstEntity: movable.buffer[i].entity!, 
                        secondEntity: immovable.buffer[other].entity!
                    )
                case .collide:
                    resolveCollision(movableIndex: i, immovableIndex: other)
                case .collideNotify:
                    delegate?.notifyCollisionOf(
                        firstEntity: movable.buffer[i].entity!, 
                        secondEntity: immovable.buffer[other].entity!
                    )
                    resolveCollision(movableIndex: i, immovableIndex: other)
                case .none: break
                }
            }

            guard i < movable.buffer.count - 1 else {
                continue
            }

            for other in (i + 1)..<movable.buffer.count where movable.buffer[other].isValid {
                let collisionType = CollisionType(
                    lCategory: movable.buffer[i].categoryBitmask, 
                    lCollision: movable.buffer[i].collisionBitmask, 
                    lNotify: movable.buffer[i].notificationBitmask, 
                    rCategory: movable.buffer[other].categoryBitmask, 
                    rCollision: 0, 
                    rNotify: 0
                )

                if 
                    collisionType == .none
                    || determineCollision(
                        lCenter: movable.buffer[i].positionCenter, 
                        lRadius: movable.buffer[i].squareRadius, 
                        rCenter: movable.buffer[other].positionCenter, 
                        rRadius: movable.buffer[other].squareRadius
                    ) == false
                {
                    continue
                }

                switch collisionType {
                case .notify:
                    delegate?.notifyCollisionOf(
                        firstEntity: movable.buffer[i].entity!, 
                        secondEntity: movable.buffer[other].entity!
                    )
                case .collide:
                    resolveCollision(movableIndex: i, secondMovableIndex: other)
                case .collideNotify:
                    delegate?.notifyCollisionOf(
                        firstEntity: movable.buffer[i].entity!, 
                        secondEntity: movable.buffer[other].entity!
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