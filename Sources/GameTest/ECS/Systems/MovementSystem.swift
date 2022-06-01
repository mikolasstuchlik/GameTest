import NoobECS
import NoobECSStores

final class MovementSystem: SDLSystem {
    override func update(with context: UpdateContext) throws {
        let storage = pool.storage(for: BoxObjectComponent.self)
        guard let movables = storage.category[.movable] else {
            return
        }

        for i in movables where storage.buffer[i] != nil {
            storage.buffer[i]!.value.frameMovementVector = 
                storage.buffer[i]!.value.velocity 
                * ( Float(context.timePassedInMs) / 1000.0)  

            storage.buffer[i]!.value.positionCenter = 
                storage.buffer[i]!.value.positionCenter 
                + storage.buffer[i]!.value.frameMovementVector
        }
    }
}