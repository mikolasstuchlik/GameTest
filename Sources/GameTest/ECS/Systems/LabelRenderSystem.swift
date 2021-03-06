import CSDL2
import NoobECS
import NoobECSStores

final class LabelRenderSystem: SDLSystem {
    override func render(with context: RenderContext) throws {
        let labelStorage = pool.storage(for: LabelComponent.self)
        let renderer = context.renderer

        guard let indicies = labelStorage.category[context.currentLayer] else {
            return
        }

        // Render
        for i in indicies where labelStorage.buffer[i] != nil {
            try labelStorage.buffer[i]!.value.prepareForRender(in: context.renderer)
            let entity = labelStorage.buffer[i]!.unownedEntity
            let center = entity.access(component: BoxObjectComponent.self, accessBlock: \.centerRect.center) ?? .zero

            if labelStorage.buffer[i]!.value.background.a > 0 {
                try renderer.setDraw(color: labelStorage.buffer[i]!.value.background)
                try renderer.drawFill(rect: SDL_Rect(CenterRect(
                    center: center + labelStorage.buffer[i]!.value.position, 
                    range: labelStorage.buffer[i]!.value.size * 0.5
                )))
            }

            try! renderer.render(
                labelStorage.buffer[i]!.value.ownedTexture, 
                source: nil, 
                destination: SDL_Rect(CenterRect(
                    center: center + labelStorage.buffer[i]!.value.position, 
                    range: labelStorage.buffer[i]!.value.size * 0.5
                ))
            )
        }
    }
}
