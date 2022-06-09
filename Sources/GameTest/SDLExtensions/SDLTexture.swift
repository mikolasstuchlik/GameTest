import CSDL2

typealias SDLTexturePtr = UnsafeMutablePointer<SDL_Texture>

extension SDLTexturePtr {
    init(for asset: Assets.Image, using renderer: SDLRendererPtr) throws {
        let tmpSurface = IMG_Load(asset.url.path)
        defer { SDL_FreeSurface(tmpSurface) }
        self = try renderer.createTextureFromSurface(from: tmpSurface!)
    }

    init(for asset: Assets.Sheet, using renderer: SDLRendererPtr) throws {
        let tmpSurface = IMG_Load(asset.url.path)
        defer { SDL_FreeSurface(tmpSurface) }
        self = try renderer.createTextureFromSurface(from: tmpSurface!)
    }

    func query(size: Size<CInt>) throws {
        var mutableSize = size
        try sdlException { SDL_QueryTexture(self, nil, nil, &mutableSize.width, &mutableSize.height) }
    }
}
