import CSDL2

final class UserInputSystem: System {

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

        for i in 0..<ControllerComponent.storage.count where ControllerComponent.storage[i].isValid {
            guard 
                ControllerComponent.storage[i].respondsTo(key: key, pressed: pressed)
            else {
                continue
            }

            let entity = ControllerComponent.storage[i].entity!

            entity.access(component: MovableObjectComponent.self) { positionComponent in

                let controller = ControllerComponent.storage[i]

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
