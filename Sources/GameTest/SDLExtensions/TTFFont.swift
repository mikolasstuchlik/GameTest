import CSDL2

typealias TTFFontPtr = UnsafeMutablePointer<TTF_Font>

extension TTFFontPtr {
    func renderBlend(label: String, color: SDL_Color) throws -> SDLSurfacePtr {
        try sdlException { TTF_RenderText_Blended(self, label, color) }
    }

    func renderBlendWrapped(label: String, color: SDL_Color, length: UInt32) throws -> SDLSurfacePtr {
        try sdlException { TTF_RenderText_Blended_Wrapped(self, label, color, length) }
    }

    func wrappedTexture(for label: String, using renderer: SDLRendererPtr, size: Size<CInt>, color: SDL_Color, length: UInt32) throws -> SDLTexturePtr {
        try textureFrom(surface: try renderBlendWrapped(label: label, color: color, length: length), renderer: renderer, size: size)
    }

    func texture(for label: String, using renderer: SDLRendererPtr, size: Size<CInt>, color: SDL_Color) throws -> SDLTexturePtr {
        try textureFrom(surface: try renderBlend(label: label, color: color), renderer: renderer, size: size)
    }

    private func textureFrom(surface: SDLSurfacePtr, renderer: SDLRendererPtr, size: Size<CInt>) throws -> SDLTexturePtr {
        let texture = try renderer.createTextureFromSurface(from: surface)
        SDL_FreeSurface(surface)
        try texture.query(size: size)
        return texture
    }
}