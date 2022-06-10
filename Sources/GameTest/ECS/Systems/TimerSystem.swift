import NoobECS
import NoobECSStores

protocol TimerSystemDelegate: AnyObject {
    func firedTimer(for entity: Entity, context: TimedEventsComponent.ScheduledItem, at time: UInt32)
}

final class TimerSystem: SDLSystem {
    weak var delegate: TimerSystemDelegate?

    override func update(with context: UpdateContext) throws {
        let store = pool.storage(for: TimedEventsComponent.self)

        // Be careful, this section needs to be aware of risk of non-exclusive access
        var executeItems: [(Entity, TimedEventsComponent.ScheduledItem)] = []
        for index in 0..<store.buffer.count where store.buffer[index] != nil {
            let filtered = store.buffer[index]!.value.items.filter { item in
                guard item.fireTime <= context.currentTime else {
                    return true
                }

                executeItems.append((store.buffer[index]!.unownedEntity, item))
                return false
            }

            if filtered.count == 0 {
                store.buffer[index]!.unownedEntity.destroy(component: TimedEventsComponent.self)
            }
        }

        while let toExecute = executeItems.popLast() {
            delegate?.firedTimer(for: toExecute.0, context: toExecute.1, at: context.currentTime)
        }
    }
}
