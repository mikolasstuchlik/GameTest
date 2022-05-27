import CSDL2
import NoobECS
import NoobECSStores

final class UserInputSystem: SDLSystem {
    override func update(with context: UpdateContext) throws {
        context.events.forEach(handle(event:))
    }

    private func handle(event: InputEvent) {
        let pressed: Bool
        let key: SDL_Scancode
        switch event {
        case let .keyDown(aKey):
            pressed = true
            key = aKey.keysym.scancode
        case let .keyUp(aKey):
            pressed = false
            key = aKey.keysym.scancode
        }

        let storage = pool.storage(for: ControllerComponent.self)

        for i in 0..<storage.buffer.count where storage.buffer[i] != nil {
            guard 
                storage.buffer[i]!.value.respondsTo(key: key, pressed: pressed)
            else {
                continue
            }

            let entity = storage.buffer[i]!.unownedEntity

            entity.access(component: PhysicalObjectComponent.self) { positionComponent in

                let controller = storage.buffer[i]!.value

                positionComponent.velocity.x = 
                    controller.isLeftPressed == controller.isRightPressed ? 0
                    : controller.isRightPressed ? 200.0
                    : -200.0

                positionComponent.velocity.y = 
                    controller.isTopPressed == controller.isBottomPressed ? 0
                    : controller.isBottomPressed ? 200.0
                    : -200.0

                let magnitude = positionComponent.velocity.magnitude
                let adjust = min(1.0, positionComponent.maxVelocity / magnitude)
                positionComponent.velocity = positionComponent.velocity * adjust
            }
        }
    }
}
