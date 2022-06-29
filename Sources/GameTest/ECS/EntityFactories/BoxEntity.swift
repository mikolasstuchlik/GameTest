import CSDL2
import NoobECS

extension EntityFactory {
    static let boxCategory: UInt32 = 0b100
    static let boxTag = "box"

    @discardableResult
    static func box(
        pool: SDLPool,
        position: Point<Float>,
        squareRadius: Size<Float>
    ) -> Entity {
        let box = Entity(dataManager: pool)
        try! box.assign(
            component: SpriteComponent.self, 
            options: .item,
            arguments: (
                unownedTexture: try! pool.resourceBuffer.texture(for: .bricks), 
                sourceRect: nil,
                size: squareRadius * 2
            )
        )
        try! box.assign(
            component: BoxObjectComponent.self, 
            options: .movable,
            arguments: (
                centerRect: CenterRect(center: position, range: squareRadius),
                categoryBitmask: boxCategory,
                collisionBitmask: boxCategory | playerCategory | tileCategory | bombCategory,
                notificationBitmask: 0,
                velocity: .zero, 
                maxVelocity: 200.0
            )
        )
        box.developerLabel = boxTag
        return box
    }
}
