final class MovementSystem: System {
    func update(with context: UpdateContext) throws {
        for i in 0..<MovableObjectComponent.storage.count {
            guard MovableObjectComponent.storage[i].entity != Entity.notAnIdentifier else {
                continue
            }

            MovableObjectComponent.storage[i].positionCenter = MovableObjectComponent.storage[i].positionCenter + MovableObjectComponent.storage[i].velocity
        }
    }

    func render(with context: RenderContext) throws { 

    }
}