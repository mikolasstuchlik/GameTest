import CSDL2
import NoobECS
import NoobECSStores


struct SpriteComponent: CategoryComponent {
    typealias Store = CategoryVectorStorage<Self>
    typealias Categories = Layer

    enum Layer: ComponentCategory {
        case background, enemy, avatar
    }

    static let placeholder = SpriteComponent(entity: nil, unownedTexture: nil, sourceRect: nil, size: .zero, rendererAssignedCenter: .zero)

    unowned(unsafe) var entity: Entity?

    var unownedTexture: SDLTexturePtr!
    var sourceRect: SDL_Rect?
    var size: Size<Float>
    var rendererAssignedCenter: Point<Float> = .zero

    func destroy() { }
}

extension SpriteComponent {
    init(entity: Entity, arguments: (unownedTexture: SDLTexturePtr, sourceRect: SDL_Rect?, size: Size<Float>)) throws {
        self.entity = entity
        self.sourceRect = arguments.sourceRect
        self.unownedTexture = arguments.unownedTexture
        self.size = arguments.size
    }
}
