import CSDL2

final class RenderSystem: System {
    var renderer: SDLRendererPtr!

    init(renderer: SDLRendererPtr!) {
        self.renderer = renderer
    }

    func update(with context: UpdateContext) throws {
        
    }

    func render(with context: RenderContext) throws {
        // Determine how many layers there are and how many items are in them
        var layers: [UInt: Int] = [:]
        for i in 0..<SpriteComponent.storage.count where SpriteComponent.storage[i].isValid {
            let entity = SpriteComponent.storage[i].entity!
            layers[SpriteComponent.storage[i].layer, default: 0] += 1
            entity.access(component: ImmovableObjectComponent.self) { immovable in
                SpriteComponent.storage[i].rendererAssignedCenter = immovable.positionCenter
            }
            entity.access(component: MovableObjectComponent.self) { movable in
                SpriteComponent.storage[i].rendererAssignedCenter = movable.positionCenter
            }
        }

        // Create map that will tell us where to store members of the layers in render queue
        var startOffset = 0
        let offsets = layers.sorted { $0.key < $1.key }.map { value -> (UInt, Int) in
            defer { startOffset += value.value }
            return (value.key, startOffset)
        }
        var startingOffsetMap = Dictionary(offsets) { $1 }

        // Allocate efficiently render queue
        var renderOrder: [Int] = .init(repeating: 0, count: SpriteComponent.storage.count - SpriteComponent.freedIndicies.count)

        // Fill the render queue (update offsets so the map is always up-to-date)
        for i in 0..<SpriteComponent.storage.count where SpriteComponent.storage[i].isValid {
            let offset = startingOffsetMap[SpriteComponent.storage[i].layer]!
            startingOffsetMap[SpriteComponent.storage[i].layer]! += 1
            renderOrder[offset] = i
        }

        // Render
        for i in renderOrder {
            try! renderer.render(
                SpriteComponent.storage[i].texture, 
                source: nil, 
                destination: SDL_Rect(Rect(
                    center: SpriteComponent.storage[i].rendererAssignedCenter, 
                    size: SpriteComponent.storage[i].size
                ))
            )
        }

        // Note - it might be just simpler to go through the storage once and then order all the items once layer is know ... or pre-order them upon insert. This is just a demo, whatever.
    }
}