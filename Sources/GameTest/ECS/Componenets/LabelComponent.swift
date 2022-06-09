import CSDL2
import NoobECS
import NoobECSStores

struct LabelComponent: CategoryComponent {
    typealias Store = CategoryVectorStorage<Self>
    typealias Categories = Layer

    private(set) var ownedTexture: SDLTexturePtr!
    var unownedFont: TTFFontPtr! { didSet { shouldRender = unownedFont != oldValue } }
    var string: String { didSet { shouldRender = string != oldValue } }
    var color: SDL_Color { didSet { shouldRender = color != oldValue } }
    var wrapLength: UInt32 { didSet { shouldRender = wrapLength != oldValue } }
    var shouldRender: Bool
    var position: Vector<Float>
    var size: Size<Float>

    init(arguments: (
        unownedFont: TTFFontPtr, 
        string: String, 
        color: SDL_Color,
        wrapLength: UInt32,
        size: Size<Float>, 
        position: Vector<Float>
    )) throws {
        self.unownedFont = arguments.unownedFont
        self.string = arguments.string
        self.size = arguments.size
        self.color = arguments.color
        self.wrapLength = arguments.wrapLength
        self.position = arguments.position
        self.shouldRender = true
    }

    private func render(in renderer: SDLRendererPtr) throws -> SDLTexturePtr {
        if wrapLength == 0 {
            return try unownedFont.texture(for: string, using: renderer, size: Size<CInt>(size), color: color)
        } else {
            return try unownedFont.wrappedTexture(for: string, using: renderer, size: Size<CInt>(size), color: color, length: wrapLength)
        }
    }

    mutating func prepareForRender(in renderer: SDLRendererPtr) throws {
        guard shouldRender else {
            return
        }

        shouldRender = false
        ownedTexture.flatMap(SDL_DestroyTexture(_:))
        ownedTexture = try render(in: renderer)
    }

    func destroy() {
        SDL_DestroyTexture(ownedTexture)
    }
}
