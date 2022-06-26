import CSDL2
import NoobECS


extension EntityFactory {
    static let bombCategory: UInt32 = 0b1000
    static let bombTag = "bomb"
    static let bombExplosionTimerTag = "bombExplosionTimer"
    static let bombSquareRadius = Size<Float>(width: 32, height: 32)
    static let bombFireTime: UInt32 = 4000
    static let bombFireAfterHit: UInt32 = 100

    @discardableResult
    static func bomb(
        pool: SDLPool,
        player: Entity,
        position: Point<Float>,
        fireTime: UInt32
    ) -> Entity {
        let bomb = Entity(dataManager: pool)
        bomb.developerLabel = EntityFactory.bombTag

        try! bomb.assign(
            component: BoxObjectComponent.self, 
            options: .immovable,
            arguments: (
                positionCenter: position,
                squareRadius: EntityFactory.bombSquareRadius,
                categoryBitmask: bombCategory,
                collisionBitmask: boxCategory | playerCategory,
                notificationBitmask: explosionCategory,
                velocity: .zero, 
                maxVelocity: 0
            )
        )
        try! bomb.assign(
            component: SpriteComponent.self, 
            options: .item,
            arguments: (
                unownedTexture: try! pool.resourceBuffer.texture(for: .bomb), 
                sourceRect: nil,
                size: EntityFactory.bombSquareRadius * 2
            )
        )
        try! bomb.assign(
            component: AnimationComponent.self,
            arguments: (
                spriteSheet: BombSheet.self,
                startTime: 0,
                currentAnimation: nil
            )
        )
        try! bomb.assign(component: TimedEventsComponent.self, arguments: ())
        let playerComponent = player.access(component: PlayerComponent.self) { $0 }
        try! bomb.assign(
            component: BombComponent.self, 
            arguments: (
                flameLength: playerComponent!.flameLength,
                summoningPlayer: ObjectIdentifier(player)
            )
        )

        bomb.access(component: TimedEventsComponent.self) { timer in
            timer.items.append(TimedEventsComponent.ScheduledItem(
                tag: EntityFactory.bombExplosionTimerTag, 
                fireTime: fireTime, 
                associatedEntities: []
            ))
        }

        if let collisionSystem = pool.systems.compactMap( { $0 as? AABBCollisionSystem }).first {
            let playerEntities = collisionSystem
                .collisions(for: bomb)
                .filter { $0.developerLabel == EntityFactory.playerTag }
                .map { ObjectIdentifier($0) }
            try! bomb.assign(component: CollisionExceptionComponent.self, arguments: Set(playerEntities))
        }

        return bomb
    }
}
