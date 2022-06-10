import CSDL2
import NoobECS


extension EntityFactory {
    static let bombCategory: UInt32 = 0b1000

    @discardableResult
    static func bomb(
        pool: SDLPool,
        position: Point<Float>,
        fireTime: UInt32
    ) -> Entity {
        let bomb = Entity(dataManager: pool)
        bomb.developerLabel = "bomb"

        let squareRadius = Size<Float>(width: 32, height: 32)

        try! bomb.assign(
            component: BoxObjectComponent.self, 
            options: .immovable,
            arguments: (
                positionCenter: position,
                squareRadius: squareRadius,
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
                unownedTexture: try! pool.textureBuffer.texture(for: .bomb), 
                sourceRect: nil,
                size: squareRadius * 2
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

        bomb.access(component: TimedEventsComponent.self) { timer in
            timer.items.append(TimedEventsComponent.ScheduledItem(
                tag: "bombExplosionTimer", 
                fireTime: fireTime, 
                associatedEntities: []
            ))
        }

        return bomb
    }
}
