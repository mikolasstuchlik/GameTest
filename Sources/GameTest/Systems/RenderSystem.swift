import CSDL2

final class RenderSystem: System {
    var renderer: SDLRendererPtr!

    init(renderer: SDLRendererPtr!) {
        self.renderer = renderer
    }

    func update(with context: UpdateContext) throws {
        
    }

    func render(with context: RenderContext) throws {
        for i in 0..<SpriteComponent.storage.count where SpriteComponent.storage[i].isValid {
            let entity = SpriteComponent.storage[i].entity!
            let spriteSize = SpriteComponent.storage[i].size
            
            entity.access(component: ImmovableObjectComponent.self) { immovable in
                try! renderer.render(
                    SpriteComponent.storage[i].texture, 
                    source: nil, 
                    destination: SDL_Rect(Rect(center: immovable.positionCenter, size: spriteSize))
                )
            }

            entity.access(component: MovableObjectComponent.self) { movable in
                try! renderer.render(
                    SpriteComponent.storage[i].texture, 
                    source: nil, 
                    destination: SDL_Rect(Rect(center: movable.positionCenter, size: spriteSize))
                )
            }
        }
    }
}
