import NoobECS
import NoobECSStores

protocol TimerSystemDelegate: AnyObject {
    func firedTimer(for entity: Entity, context: TimedEventsComponent.ScheduledItem)
}

final class TimerSystem: SDLSystem {
    weak var delegate: TimerSystemDelegate?

    override func update(with context: UpdateContext) throws {
        let store = pool.storage(for: TimedEventsComponent.self)

        for index in 0..<store.buffer.count where store.buffer[index] != nil {
            store.buffer[index]!.value.items.filter { item in
                guard item.fireTime <= context.currentTime else {
                    return true
                }

                delegate?.firedTimer(for: store.buffer[index]!.unownedEntity, context: item)
                return false
            }

            /// We are not sure, what action was taken in delegate, so we need to check validity again
            guard store.buffer[index] != nil else {
                continue
            }

            if store.buffer[index]!.value.items.count == 0 {
                store.buffer[index]!.unownedEntity.destroy(component: TimedEventsComponent.self)
            }
        }
    }
}
