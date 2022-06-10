import NoobECS
import NoobECSStores

final class AnimationSystem: SDLSystem {
    override func update(with context: UpdateContext) throws {
        let storage = pool.storage(for: AnimationComponent.self)

        for i in 0..<storage.buffer.count where storage.buffer[i] != nil {
            let entity = storage.buffer[i]!.unownedEntity
            let newAnimation = storage.buffer[i]!.value.spriteSheet.nextAnimation(
                for: entity, 
                current: storage.buffer[i]!.value.currentAnimation
            )

            if storage.buffer[i]!.value.currentAnimation != newAnimation {
                storage.buffer[i]!.value.currentAnimation = newAnimation
                storage.buffer[i]!.value.startTime = context.currentTime
            }

            guard 
                let currentName = storage.buffer[i]!.value.currentAnimation,
                let animation = storage.buffer[i]!.value.spriteSheet.animations[currentName],
                animation.tiles.count > 0
            else {
                setFrame(sheet: storage.buffer[i]!.value.spriteSheet, tile: nil, to: entity)
                continue
            }

            // This computation is broken
            let animationDurationInMs = context.currentTime - storage.buffer[i]!.value.startTime
            let milisecsInSecond = 1000
            let frameDuration = milisecsInSecond / animation.fps
            let currentFrame = Int(animationDurationInMs) / frameDuration
            let frameIndex = currentFrame % animation.tiles.count

            setFrame(
                sheet: storage.buffer[i]!.value.spriteSheet, 
                tile: animation.tiles[frameIndex], 
                to: entity
            )
        }
    }

    private func setFrame(sheet: SpriteSheet.Type, tile: Int?, to entity: Entity) {
        let tile = tile ?? sheet.defaultTile
        let rect = sheet.rectFor(tileIndex: tile)
        entity.access(component: SpriteComponent.self) { sprite in
            sprite.sourceRect = rect
        }
    }
}