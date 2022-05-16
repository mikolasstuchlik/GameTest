import CLibs

struct SpriteComponent: Component {
    static var storage: [Self] = []
    static var freedIndicies: [Int] = []
    
    unowned(unsafe) var entity: Entity?
    var texture: SDLTexturePtr
    var size: Size<Float>

    init(entity: Entity, arguments: (asset: Assets.Image, size: Size<Float>)) throws {
        self.entity = entity
        texture = try SDLTexturePtr.init(for: arguments.asset)
        size = arguments.size
    }

    func destroy() {
        SDL_DestroyTexture(texture)
    }
}