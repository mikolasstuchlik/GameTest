import NoobECS
import NoobECSStores

struct TimedEventsComponent: Component {
    typealias Store = VectorStorage<Self>

    struct ScheduledItem {
        var tag: String
        var fireTime: UInt32
        var associatedEntities: Set<Entity>
    }

    var items: [ScheduledItem] = []

    init(arguments: Void) { }
}
