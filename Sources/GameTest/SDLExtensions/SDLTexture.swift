import CSDL2

typealias SDLTexturePtr = UnsafeMutablePointer<SDL_Texture>

extension SDLTexturePtr {
    init(for asset: Assets.Image, using renderer: SDLRendererPtr) throws {
        let tmpSurface = IMG_Load(asset.url.path)
        defer { SDL_FreeSurface(tmpSurface) }
        self = try renderer.createTextureFromSurface(from: tmpSurface!)
    }
}
