import CSDL2

final class UserInputSystem: System {
    unowned(unsafe) let pool: Pool

    init(pool: Pool) {
        self.pool = pool
    }

    func update(with context: UpdateContext) throws {
        let pressed: Bool
        let key: SDL_Scancode
        switch context.events {
        case let .keyDown(aKey):
            pressed = true
            key = aKey.keysym.scancode
        case let .keyUp(aKey):
            pressed = false
            key = aKey.keysym.scancode
        case .none:
            return
        }

        let storage = pool.storage(for: ControllerComponent.self)

        for i in 0..<storage.buffer.count where storage.buffer[i].isValid {
            guard 
                storage.buffer[i].respondsTo(key: key, pressed: pressed)
            else {
                continue
            }

            let entity = storage.buffer[i].entity!

            entity.access(component: MovableObjectComponent.self) { positionComponent in

                let controller = storage.buffer[i]

                positionComponent.velocity.x = 
                    controller.isLeftPressed == controller.isRightPressed ? 0
                    : controller.isRightPressed ? 1.0
                    : -1.0

                positionComponent.velocity.y = 
                    controller.isTopPressed == controller.isBottomPressed ? 0
                    : controller.isBottomPressed ? 1.0
                    : -1.0

                let magnitude = positionComponent.velocity.magnitude
                let adjust = min(1.0, positionComponent.maxVelocity / magnitude)
                positionComponent.velocity = positionComponent.velocity * adjust
            }
        }
    }

    func render(with context: RenderContext) throws {
    }
}
