import CLibs

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

        for i in 0..<ControllerComponent.storage.count {
            guard 
                ControllerComponent.storage[i].entity != Entity.notAnIdentifier,
                ControllerComponent.storage[i].respondsTo(key: key, pressed: pressed),
                let entity = Entity.unpackUnownedEntity(from: ControllerComponent.storage[i].entity)
            else {
                continue
            }

            entity.access(component: MovableObjectComponent.self) { positionComponent in
                guard let positionComponent = positionComponent else { return }

                let controller = ControllerComponent.storage[i]

                positionComponent.pointee.velocity.x = 
                    controller.isLeftPressed == controller.isRightPressed ? 0
                    : controller.isRightPressed ? 1.0
                    : -1.0

                positionComponent.pointee.velocity.y = 
                    controller.isTopPressed == controller.isBottomPressed ? 0
                    : controller.isBottomPressed ? 1.0
                    : -1.0

                let magnitude = positionComponent.pointee.velocity.magnitude
                let adjust = min(1.0, positionComponent.pointee.maxVelocity / magnitude)
                positionComponent.pointee.velocity = positionComponent.pointee.velocity * adjust
            }
        }
    }

    func render(with context: RenderContext) throws {
    }
}