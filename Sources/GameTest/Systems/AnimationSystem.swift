final class AnimationSystem: System {
    weak var pool: Pool!

    init(pool: Pool) {
        self.pool = pool
    }

    func update(with context: UpdateContext) throws {
        let storage = pool.storage(for: AnimationComponent.self)

        for i in 0..<storage.buffer.count where storage.buffer[i].isValid {
            let entity = storage.buffer[i].entity!
            let newAnimation = storage.buffer[i].spriteSheet.nextAnimation(
                for: entity, 
                current: storage.buffer[i].currentAnimation
            )

            if storage.buffer[i].currentAnimation != newAnimation {
                storage.buffer[i].currentAnimation = newAnimation
                storage.buffer[i].startTime = context.currentTime
            }

            guard 
                let currentName = storage.buffer[i].currentAnimation,
                let animation = storage.buffer[i].spriteSheet.animations[currentName],
                animation.tiles.count > 0
            else {
                setFrame(sheet: storage.buffer[i].spriteSheet, tile: nil, to: entity)
                continue
            }

            let animationDurationInMs = context.currentTime - storage.buffer[i].startTime
            let milisecsInSecond = 1000
            let frameDuration = milisecsInSecond / animation.fps
            let currentFrame = Int(animationDurationInMs) / frameDuration
            let frameIndex = currentFrame % animation.tiles.count

            setFrame(
                sheet: storage.buffer[i].spriteSheet, 
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

    func render(with context: RenderContext) throws { 

    }
}