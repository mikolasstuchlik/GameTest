import CSDL2
import NoobECS


extension EntityFactory {
    static let boxCategory: UInt32 = 0b100
    static let bombFireTime: UInt32 = 4000
    static let bombFireAfterHit: UInt32 = 100

    @discardableResult
    static func box(
        pool: SDLPool,
        asset: Assets.Image,
        position: Point<Float>,
        squareRadius: Size<Float>
    ) -> Entity {
        let box = Entity(dataManager: pool)
        try! box.assign(
            component: SpriteComponent.self, 
            options: .item,
            arguments: (
                unownedTexture: try! pool.resourceBuffer.texture(for: asset), 
                sourceRect: nil,
                size: squareRadius * 2
            )
        )
        try! box.assign(
            component: BoxObjectComponent.self, 
            options: .movable,
            arguments: (
                positionCenter: position,
                squareRadius: squareRadius,
                categoryBitmask: boxCategory,
                collisionBitmask: boxCategory | playerCategory | tileCategory | bombCategory,
                notificationBitmask: 0,
                velocity: .zero, 
                maxVelocity: 200.0
            )
        )
        return box
    }
}
