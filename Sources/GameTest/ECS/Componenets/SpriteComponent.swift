import CSDL2
import NoobECS
import NoobECSStores

struct SpriteComponent: CategoryComponent {
    typealias Store = CategoryVectorStorage<Self>
    typealias Categories = Layer

    var unownedTexture: SDLTexturePtr
    var sourceRect: SDL_Rect?
    var size: Size<Float>

    init(arguments: (unownedTexture: SDLTexturePtr, sourceRect: SDL_Rect?, size: Size<Float>)) throws {
        self.sourceRect = arguments.sourceRect
        self.unownedTexture = arguments.unownedTexture
        self.size = arguments.size
    }
}
