import CSDL2

final class TextureBuffer {
    private weak var pool: Pool?
    private var imageBuffer: [Assets.Image: SDLTexturePtr] = [:]
    private var sheetBuffer: [Assets.Sheet: SDLTexturePtr] = [:]

    init(pool: Pool) {
        self.pool = pool
    }

    func texture(for image: Assets.Image) throws -> SDLTexturePtr {
        if let result = imageBuffer[image] {
            return result
        }

        let new = try SDLTexturePtr(for: image, using: pool!.application.renderer)
        imageBuffer[image] = new
        return new
    }

    func texture(for sheet: Assets.Sheet) throws -> SDLTexturePtr {
        if let result = sheetBuffer[sheet] {
            return result
        }

        let new = try SDLTexturePtr(for: sheet, using: pool!.application.renderer)
        sheetBuffer[sheet] = new
        return new
    }

    deinit {
        imageBuffer.values.forEach(SDL_DestroyTexture(_:))
        sheetBuffer.values.forEach(SDL_DestroyTexture(_:))
    }
}