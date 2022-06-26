import NoobECS
import NoobECSStores

struct CollisionExceptionComponent: Component {
    typealias Store = VectorStorage<Self>

    var collisionException: Set<ObjectIdentifier>

    init(
        arguments: Set<ObjectIdentifier>
    ) {
        self.collisionException = arguments
    }
}