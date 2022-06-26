import CSDL2
import NoobECS
import NoobECSStores

final class UserInputSystem: SDLSystem {

    private var storage: ControllerComponent.Store!
    override func update(with context: UpdateContext) throws {
        self.storage = pool.storage(for: ControllerComponent.self)
        defer { self.storage = nil }

        context.events.forEach(handle(event:))
        for i in 0..<storage.buffer.count where storage.buffer[i] != nil {
            handleBombPlant(for: i, currentTime: context.currentTime)
        }
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
        default: return
        }

        for i in 0..<storage.buffer.count where storage.buffer[i] != nil {
            guard 
                storage.buffer[i]!.value.respondsTo(key: key, pressed: pressed)
            else {
                continue
            }

            handleMovementInput(for: i)
        }
    }

    private func handleMovementInput(for index: Int) {
        let entity = storage.buffer[index]!.unownedEntity

        entity.access(component: BoxObjectComponent.self) { positionComponent in

            let controller = storage.buffer[index]!.value

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

    private func handleBombPlant(for index: Int, currentTime: UInt32) {
        guard  
            storage.buffer[index]!.value.shouldSummonBomb,
            let collisionSystem = pool.systems.compactMap({ $0 as? AABBCollisionSystem }).first 
        else { return }

        storage.buffer[index]!.value.shouldSummonBomb = false
        let position = Map.alignToGrid(point:
            storage.buffer[index]!.unownedEntity.access(component: BoxObjectComponent.self, accessBlock: \.positionCenter)!
        )
        
        let collidingEntites = collisionSystem.entities(in: Rect(
            center: position,
            radius: EntityFactory.bombSquareRadius
        ))

        guard !collidingEntites.contains(where: { $0.has(component: BombComponent.self) }) else {
            return
        } 

        let canDeploy = storage.buffer[index]!.unownedEntity.access(component: PlayerComponent.self) { component -> Bool in 
            guard component.bombDeployed < component.bombLimit else {
                return false
            }

            component.bombDeployed += 1
            return true
        }

        guard canDeploy == true else { return }

        EntityFactory.bomb(
            pool: pool as! SDLPool,
            player: storage.buffer[index]!.unownedEntity,
            position: position, 
            fireTime: currentTime + EntityFactory.bombFireTime
        )
    }
}
