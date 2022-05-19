import CSDL2

final class RenderSystem: SDLSystem {
    override func render(with context: RenderContext) throws {
        let spriteStore = pool.storage(for: SpriteComponent.self)
        let renderer = context.renderer

        // Render
        for i in 0..<spriteStore.buffer.count where spriteStore.buffer[i].isValid {
            let entity = spriteStore.buffer[i].entity!
            entity.access(component: PhysicalObjectComponent.self) { immovable in
                spriteStore.buffer[i].rendererAssignedCenter = immovable.positionCenter
            }

            try! renderer.render(
                spriteStore.buffer[i].unownedTexture, 
                source: spriteStore.buffer[i].sourceRect, 
                destination: SDL_Rect(Rect(
                    center: spriteStore.buffer[i].rendererAssignedCenter, 
                    size: spriteStore.buffer[i].size
                ))
            )
        }
    }
}
