final class MovementSystem: System {
    func update(with context: UpdateContext) throws {
        for i in 0..<MovementComponent.storage.count {
            guard MovementComponent.storage[i].entity != Entity.notAnIdentifier else {
                continue
            }

            MovementComponent.storage[i].position = MovementComponent.storage[i].position + MovementComponent.storage[i].velocity
        }
    }

    func render(with context: RenderContext) throws { 

    }
}