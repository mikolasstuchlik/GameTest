import NoobECS

class SDLPool: Pool<SDLUpdateContext, SDLRenderContext> {
    let getRenderer: () -> SDLRendererPtr?
    lazy var textureBuffer = TextureBuffer(pool: self)

    init(getRenderer: @escaping () -> SDLRendererPtr?) {
        self.getRenderer = getRenderer
        super.init()
    }
}
