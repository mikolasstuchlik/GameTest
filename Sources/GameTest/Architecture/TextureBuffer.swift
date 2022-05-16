import CSDL2

final class TextureBuffer {
    private weak var pool: Pool?
    private var buffer: [Assets.Image: SDLTexturePtr] = [:]

    init(pool: Pool) {
        self.pool = pool
    }

    func texture(for image: Assets.Image) throws -> SDLTexturePtr {
        if let result = buffer[image] {
            return result
        }

        let new = try SDLTexturePtr(for: image, using: pool!.application.renderer)
        buffer[image] = new
        return new
    }

    deinit {
        buffer.values.forEach(SDL_DestroyTexture(_:))
    }
}