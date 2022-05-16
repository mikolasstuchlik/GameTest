import CSDL2

struct SpriteComponent: Component {
    unowned(unsafe) var entity: Entity?

    var unownedTexture: SDLTexturePtr
    var size: Size<Float>
    var layer: UInt
    var rendererAssignedCenter: Point<Float> = .zero

    init(entity: Entity, arguments: (unownedTexture: SDLTexturePtr, size: Size<Float>, layer: UInt)) throws {
        self.entity = entity
        self.unownedTexture = arguments.unownedTexture
        self.size = arguments.size
        self.layer = arguments.layer
    }

    func destroy() { }
}
