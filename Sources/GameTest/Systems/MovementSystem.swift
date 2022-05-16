final class MovementSystem: System {
    unowned(unsafe) let pool: Pool

    init(pool: Pool) {
        self.pool = pool
    }

    func update(with context: UpdateContext) throws {
        let storage = pool.storage(for: MovableObjectComponent.self)

        for i in 0..<storage.buffer.count where storage.buffer[i].isValid {
            storage.buffer[i].startingPosition = storage.buffer[i].positionCenter
            storage.buffer[i].positionCenter = storage.buffer[i].positionCenter + storage.buffer[i].velocity
        }
    }

    func render(with context: RenderContext) throws { 

    }
}