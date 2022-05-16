import CLibs

final class RenderSystem: System {
    var renderer: SDLRendererPtr!

    init(renderer: SDLRendererPtr!) {
        self.renderer = renderer
    }

    func update(with context: UpdateContext) throws {
        
    }

    func render(with context: RenderContext) throws {
        try Entity.entities.lazy.filter { 
            $0.has(component: MovableObjectComponent.self) 
            && $0.has(component: SpriteComponent.self)
        }.forEach { entity in
            try entity.access(component: MovableObjectComponent.self) { position in
                try entity.access(component: SpriteComponent.self) { sprite in
                    try renderer.render(
                        sprite.texture, 
                        source: nil, 
                        destination: SDL_Rect(
                            x: CInt(position.positionCenter.x),
                            y: CInt(position.positionCenter.y),
                            w: CInt(sprite.size.width),
                            h: CInt(sprite.size.height)
                        )
                    )
                }
            }
        }
    }
}