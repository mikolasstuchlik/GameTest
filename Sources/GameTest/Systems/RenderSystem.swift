import CSDL2

final class RenderSystem: System {
    weak var pool: Pool!

    init(pool: Pool) {
        self.pool = pool
    }

    func update(with context: UpdateContext) throws {
        
    }

    func render(with context: RenderContext) throws {
        let spriteStore = pool.storage(for: SpriteComponent.self)
        let renderer = pool.application.renderer!

        // Determine how many layers there are and how many items are in them
        var layers: [UInt: Int] = [:]
        for i in 0..<spriteStore.buffer.count where spriteStore.buffer[i].isValid {
            let entity = spriteStore.buffer[i].entity!
            layers[spriteStore.buffer[i].layer, default: 0] += 1
            entity.access(component: ImmovableObjectComponent.self) { immovable in
                spriteStore.buffer[i].rendererAssignedCenter = immovable.positionCenter
            }
            entity.access(component: MovableObjectComponent.self) { movable in
                spriteStore.buffer[i].rendererAssignedCenter = movable.positionCenter
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
        var renderOrder: [Int] = .init(repeating: 0, count: spriteStore.buffer.count)

        // Fill the render queue (update offsets so the map is always up-to-date)
        for i in 0..<spriteStore.buffer.count where spriteStore.buffer[i].isValid {
            let offset = startingOffsetMap[spriteStore.buffer[i].layer]!
            startingOffsetMap[spriteStore.buffer[i].layer]! += 1
            renderOrder[offset] = i
        }

        // Render
        for i in renderOrder {
            try! renderer.render(
                spriteStore.buffer[i].unownedTexture, 
                source: spriteStore.buffer[i].sourceRect, 
                destination: SDL_Rect(Rect(
                    center: spriteStore.buffer[i].rendererAssignedCenter, 
                    size: spriteStore.buffer[i].size
                ))
            )
        }

        // Note - it might be just simpler to go through the storage once and then order all the items once layer is know ... or pre-order them upon insert. This is just a demo, whatever.
    }
}