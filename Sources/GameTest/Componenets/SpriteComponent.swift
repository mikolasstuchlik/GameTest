import CSDL2

struct SpriteComponent: Component {
    typealias Store = VectorStorage<Self>

    unowned(unsafe) var entity: Entity?

    var unownedTexture: SDLTexturePtr
    var sourceRect: SDL_Rect?
    var size: Size<Float>
    var layer: UInt
    var rendererAssignedCenter: Point<Float> = .zero

    init(entity: Entity, arguments: (unownedTexture: SDLTexturePtr, sourceRect: SDL_Rect?, size: Size<Float>, layer: UInt)) throws {
        self.entity = entity
        self.sourceRect = arguments.sourceRect
        self.unownedTexture = arguments.unownedTexture
        self.size = arguments.size
        self.layer = arguments.layer
    }

    func destroy() { }
}
