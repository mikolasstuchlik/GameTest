import CSDL2
import NoobECS
import NoobECSStores

final class RenderSystem: SDLSystem {
    override func render(with context: RenderContext) throws {
        let spriteStore = pool.storage(for: SpriteComponent.self)
        let renderer = context.renderer

        // Render
        for i in 0..<spriteStore.buffer.count where spriteStore.buffer[i] != nil {
            let entity = spriteStore.buffer[i]!.unownedEntity
            entity.access(component: PhysicalObjectComponent.self) { immovable in
                spriteStore.buffer[i]!.value.rendererAssignedCenter = immovable.positionCenter
            }

            try! renderer.render(
                spriteStore.buffer[i]!.value.unownedTexture, 
                source: spriteStore.buffer[i]!.value.sourceRect, 
                destination: SDL_Rect(Rect(
                    center: spriteStore.buffer[i]!.value.rendererAssignedCenter, 
                    size: spriteStore.buffer[i]!.value.size
                ))
            )
        }
    }
}
