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
            $0.has(component: MovementComponent.self) 
            && $0.has(component: SpriteComponent.self)
        }.forEach { entity in
            try entity.access(component: MovementComponent.self) { position in
                try entity.access(component: SpriteComponent.self) { sprite in
                    try renderer.render(
                        sprite!.pointee.texture, 
                        source: nil, 
                        destination: SDL_Rect(
                            x: CInt(position!.pointee.position.x),
                            y: CInt(position!.pointee.position.y),
                            w: CInt(sprite!.pointee.size.width),
                            h: CInt(sprite!.pointee.size.height)
                        )
                    )
                }
            }
        }
    }
}