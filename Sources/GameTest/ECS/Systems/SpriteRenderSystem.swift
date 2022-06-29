import CSDL2
import NoobECS
import NoobECSStores

final class SpriteRenderSystem: SDLSystem {
    override func render(with context: RenderContext) throws {
        let spriteStore = pool.storage(for: SpriteComponent.self)
        let renderer = context.renderer

        guard let indicies = spriteStore.category[context.currentLayer] else {
            return
        }

        // Render
        for i in indicies where spriteStore.buffer[i] != nil {
            let entity = spriteStore.buffer[i]!.unownedEntity
            let center = entity.access(component: BoxObjectComponent.self, accessBlock: \.positionCenter) ?? .zero

            try! renderer.render(
                spriteStore.buffer[i]!.value.unownedTexture, 
                source: spriteStore.buffer[i]!.value.sourceRect, 
                destination: SDL_Rect(CenterRect(
                    center: center, 
                    range: spriteStore.buffer[i]!.value.size * 0.5
                ))
            )
        }
    }
}
