import CSDL2
import NoobECS
import NoobECSStores

struct LabelComponent: CategoryComponent {
    typealias Store = CategoryVectorStorage<Self>
    typealias Categories = Layer

    private(set) var ownedTexture: SDLTexturePtr
    var position: Vector<Float>
    var size: Size<Float>

    init(arguments: (ownedTexture: SDLTexturePtr, position: Vector<Float>, size: Size<Float>)) throws {
        self.ownedTexture = arguments.ownedTexture
        self.position = arguments.position
        self.size = arguments.size
    }

    mutating func replaceTexture(with newTexture: SDLTexturePtr) {
        SDL_DestroyTexture(ownedTexture)
        ownedTexture = newTexture
    }

    func destroy() {
        SDL_DestroyTexture(ownedTexture)
    }
}
