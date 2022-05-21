import NoobECS
import NoobECSStores

final class MovementSystem: SDLSystem {
    override func update(with context: UpdateContext) throws {
        let storage = pool.storage(for: PhysicalObjectComponent.self)
        guard let movables = storage.category[.movable] else {
            return
        }

        for i in movables where storage.buffer[i].isValid {
            storage.buffer[i].startingPosition = storage.buffer[i].positionCenter

            storage.buffer[i].positionCenter = storage.buffer[i].positionCenter 
                + storage.buffer[i].velocity
                * ( Float(context.timePassedInMs) / 1000.0)  
        }
    }
}