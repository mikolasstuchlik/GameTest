import CSDL2

typealias SDLTexturePtr = UnsafeMutablePointer<SDL_Texture>

extension SDLTexturePtr {
    init(for asset: Assets.Image) throws {
        let tmpSurface = IMG_Load(asset.url.path)
        defer { SDL_FreeSurface(tmpSurface) }
        // TODO: Use some form of manager
        self = try Application.renderer!.createTextureFromSurface(from: tmpSurface!)
    }
}
