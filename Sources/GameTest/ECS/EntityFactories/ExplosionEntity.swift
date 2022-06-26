import CSDL2
import NoobECS


extension EntityFactory {
    static let explosionCategory: UInt32 = 0b10000
    static let explosionDuration: UInt32 = 500
    static let explosionTag = "explosion"
    static let explosionExpiredTag = "explosionExpired"

    static func summonExplosion(
        pool: SDLPool,
        center: Point<Float>,
        fireTime: UInt32
    ) {
        let horizontalVector = Vector<Float>(x: explosionSquareRadius.width * 2, y: 0)
        let verticalVector = Vector<Float>(x: 0, y: explosionSquareRadius.height * 2)

        explosion(pool: pool, type: .center, position: center, fireTime: fireTime)

        explosion(pool: pool, type: .horiz, position: center + horizontalVector * 1, fireTime: fireTime)
        explosion(pool: pool, type: .horiz, position: center + horizontalVector * 2, fireTime: fireTime)
        explosion(pool: pool, type: .rightTip, position: center + horizontalVector * 3, fireTime: fireTime)

        explosion(pool: pool, type: .horiz, position: center + horizontalVector * -1, fireTime: fireTime)
        explosion(pool: pool, type: .horiz, position: center + horizontalVector * -2, fireTime: fireTime)
        explosion(pool: pool, type: .leftTip, position: center + horizontalVector * -3, fireTime: fireTime)

        explosion(pool: pool, type: .vert, position: center + verticalVector * 1, fireTime: fireTime)
        explosion(pool: pool, type: .vert, position: center + verticalVector * 2, fireTime: fireTime)
        explosion(pool: pool, type: .downTip, position: center + verticalVector * 3, fireTime: fireTime)

        explosion(pool: pool, type: .vert, position: center + verticalVector * -1, fireTime: fireTime)
        explosion(pool: pool, type: .vert, position: center + verticalVector * -2, fireTime: fireTime)
        explosion(pool: pool, type: .upTip, position: center + verticalVector * -3, fireTime: fireTime)
    }

    private static let explosionSquareRadius = Size<Float>(width: 32, height: 32)

    @discardableResult
    private static func explosion(
        pool: SDLPool,
        type: ExplosionSheet.Cases,
        position: Point<Float>,
        fireTime: UInt32
    ) -> Entity {
        let explosion = Entity(dataManager: pool)
        explosion.developerLabel = EntityFactory.explosionTag

        let squareRadius = explosionSquareRadius

        try! explosion.assign(
            component: BoxObjectComponent.self, 
            // Explosion isnt really going to move, but I need the collision resolution
            options: .movable,
            arguments: (
                positionCenter: position,
                squareRadius: squareRadius,
                categoryBitmask: explosionCategory,
                collisionBitmask: 0,
                notificationBitmask: bombCategory | playerCategory,
                velocity: .zero, 
                maxVelocity: 0
            )
        )
        try! explosion.assign(
            component: SpriteComponent.self, 
            options: .item,
            arguments: (
                unownedTexture: try! pool.resourceBuffer.texture(for: .explosion), 
                sourceRect: nil,
                size: squareRadius * 2
            )
        )
        try! explosion.assign(
            component: AnimationComponent.self,
            arguments: (
                spriteSheet: ExplosionSheet.self,
                startTime: 0,
                currentAnimation: type.rawValue
            )
        )
        try! explosion.assign(component: TimedEventsComponent.self, arguments: ())

        explosion.access(component: TimedEventsComponent.self) { timer in
            timer.items.append(TimedEventsComponent.ScheduledItem(
                tag: EntityFactory.explosionExpiredTag, 
                fireTime: fireTime, 
                associatedEntities: []
            ))
        }

        return explosion
    }
}
