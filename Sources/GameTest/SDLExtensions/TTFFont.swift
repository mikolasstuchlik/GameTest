import CSDL2

typealias TTFFontPtr = UnsafeMutablePointer<TTF_Font>

extension TTFFontPtr {
    func texture(for label: String, using renderer: SDLRendererPtr, size: Size<CInt>, color: SDL_Color) throws -> SDLTexturePtr {
        let surface = TTF_RenderText_Blended(self, label, color)!
        let texture = try renderer.createTextureFromSurface(from: surface)
        SDL_FreeSurface(surface)

        var mutableSize = size
        SDL_QueryTexture(texture, nil, nil, &mutableSize.width, &mutableSize.height)

        return texture
    }
}