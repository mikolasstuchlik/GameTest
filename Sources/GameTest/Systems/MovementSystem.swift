final class MovementSystem: System {
    func update(with context: UpdateContext) throws {
        for i in 0..<PhysicsComponent.storage.count {
            guard PhysicsComponent.storage[i].entity != Entity.notAnIdentifier else {
                continue
            }

            PhysicsComponent.storage[i].positionCenter = PhysicsComponent.storage[i].positionCenter + PhysicsComponent.storage[i].velocity
        }
    }

    func render(with context: RenderContext) throws { 

    }
}