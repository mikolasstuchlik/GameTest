import CSDL2

final class TextureBuffer {
    private weak var pool: SDLPool?
    private var imageBuffer: [Assets.Image: SDLTexturePtr] = [:]
    private var sheetBuffer: [Assets.Sheet: SDLTexturePtr] = [:]
    private var fontBuffer: [Assets.Font: [CInt: TTFFontPtr]] = [:]

    init(pool: SDLPool) {
        self.pool = pool
    }

    func texture(for image: Assets.Image) throws -> SDLTexturePtr {
        if let result = imageBuffer[image] {
            return result
        }

        let new = try SDLTexturePtr(for: image, using: pool!.getRenderer()!)
        imageBuffer[image] = new
        return new
    }

    func texture(for sheet: Assets.Sheet) throws -> SDLTexturePtr {
        if let result = sheetBuffer[sheet] {
            return result
        }
        let new = try SDLTexturePtr(for: sheet, using: pool!.getRenderer()!)
        sheetBuffer[sheet] = new
        return new
    }

    func font(for font: Assets.Font, size: CInt) throws -> TTFFontPtr {
        if let result = fontBuffer[font]?[size] {
            return result
        }

        let new = try sdlException { TTF_OpenFont(font.url.path, size) }
        fontBuffer[font, default: [:]][size] = new
        return new
    }

    deinit {
        imageBuffer.values.forEach(SDL_DestroyTexture(_:))
        sheetBuffer.values.forEach(SDL_DestroyTexture(_:))
        fontBuffer.values.forEach { $0.values.forEach(TTF_CloseFont(_:)) }
    }
}
