import CSDL2

struct SpriteComponent: Component {
    static var storage: [Self] = []
    static var freedIndicies: [Int] = []
    
    unowned(unsafe) var entity: Entity?
    var texture: SDLTexturePtr
    var size: Size<Float>
    var layer: UInt
    var rendererAssignedCenter: Point<Float> = .zero

    init(entity: Entity, arguments: (asset: Assets.Image, size: Size<Float>, layer: UInt)) throws {
        self.entity = entity
        self.texture = try SDLTexturePtr.init(for: arguments.asset)
        self.size = arguments.size
        self.layer = arguments.layer
    }

    func destroy() {
        SDL_DestroyTexture(texture)
    }
}
