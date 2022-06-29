import CSDL2
import NoobECS


extension EntityFactory {
    static let explosionCategory: UInt32 = 0b10000
    static let explosionDuration: UInt32 = 500
    static let explosionTag = "explosion"
    static let explosionExpiredTag = "explosionExpired"

    static func summonExplosion(
        pool: SDLPool,
        flameLength: Int,
        center: Point<Float>,
        fireTime: UInt32,
        onExplosionHit: (Entity) -> Void
    ) {
        let horizontalVector = Vector<Float>(x: explosionSquareRadius.width * 2, y: 0)
        let verticalVector = Vector<Float>(x: 0, y: explosionSquareRadius.height * 2)

        explosion(pool: pool, type: .center, position: center, fireTime: fireTime)

        // leaf right
        for i in 1...flameLength {
            let position = center + horizontalVector * Float(i)
            let entites = explostionShouldBeStoppedByEntity(pool: pool, position: position)
            guard entites.isEmpty else {
                entites.forEach(onExplosionHit)
                break
            }
            explosion(
                pool: pool, 
                type: i == flameLength ? .rightTip : .horiz, 
                position: position, 
                fireTime: fireTime
            )
        }

        for i in 1...flameLength {
            let position = center + verticalVector * Float(i)
            let entites = explostionShouldBeStoppedByEntity(pool: pool, position: position)
            guard entites.isEmpty else {
                entites.forEach(onExplosionHit)
                break
            }
            explosion(
                pool: pool, 
                type: i == flameLength ? .downTip : .vert, 
                position: position, 
                fireTime: fireTime
            )
        }

        for i in ((-flameLength)...(-1)).reversed() {
            let position = center + horizontalVector * Float(i)
            let entites = explostionShouldBeStoppedByEntity(pool: pool, position: position)
            guard entites.isEmpty else {
                entites.forEach(onExplosionHit)
                break
            }
            explosion(
                pool: pool, 
                type: i == -flameLength ? .leftTip : .horiz, 
                position: position, 
                fireTime: fireTime
            )
        }

        for i in ((-flameLength)...(-1)).reversed() {
            let position = center + verticalVector * Float(i)
            let entites = explostionShouldBeStoppedByEntity(pool: pool, position: position)
            guard entites.isEmpty else {
                entites.forEach(onExplosionHit)
                break
            }
            explosion(
                pool: pool, 
                type: i == -flameLength ? .upTip : .vert, 
                position: position, 
                fireTime: fireTime
            )
        }
    }

    private static func explostionShouldBeStoppedByEntity(pool: SDLPool, position center: Point<Float>) -> [Entity] {
        guard let collisionSystem = pool.systems.compactMap({ $0 as? AABBCollisionSystem }).first else {
            return []
        }

        let collidingEntites = collisionSystem.entities(in: CenterRect(
            center: center,
            range: explosionCollisionRadius
        ))

        return collidingEntites.filter { entity -> Bool in
            switch entity.developerLabel {
            case EntityFactory.bombTag:
                return true
            case EntityFactory.mapWallTag:
                return true
            case EntityFactory.boxTag:
                return true
            case EntityFactory.bonusTag:
                return true
            case EntityFactory.explosionTag:
                return true
            default:
                return false
            }
        }
    }

    private static let explosionSquareRadius = Size<Float>(width: 32, height: 32)
    private static let explosionCollisionRadius = Size<Float>(width: 28, height: 28)

    @discardableResult
    private static func explosion(
        pool: SDLPool,
        type: ExplosionSheet.Cases,
        position: Point<Float>,
        fireTime: UInt32
    ) -> Entity {
        let explosion = Entity(dataManager: pool)
        explosion.developerLabel = EntityFactory.explosionTag

        try! explosion.assign(
            component: BoxObjectComponent.self, 
            // Explosion isnt really going to move, but I need the collision resolution
            options: .movable,
            arguments: (
                centerRect: CenterRect(center: position, range: explosionCollisionRadius),
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
                size: explosionSquareRadius * 2
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
