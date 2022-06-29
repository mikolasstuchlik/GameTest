import NoobECS
import NoobECSStores

struct BoxObjectComponent: CategoryComponent {
    typealias Store = CategoryVectorStorage<Self>
    enum Categories: Comparable, Hashable {
        case movable, immovable, immaterial
    }

    var centerRect: CenterRect<Float>

    var categoryBitmask: UInt32
    var collisionBitmask: UInt32
    var notificationBitmask: UInt32

    var frameMovementVector: Vector<Float>
    var velocity: Vector<Float>
    var maxVelocity: Float

    init(
        arguments: (
            centerRect: CenterRect<Float>,
            categoryBitmask: UInt32,
            collisionBitmask: UInt32,
            notificationBitmask: UInt32,
            velocity: Vector<Float>,
            maxVelocity: Float
        )
    ) {
        self.centerRect = arguments.centerRect
        self.categoryBitmask = arguments.categoryBitmask
        self.collisionBitmask = arguments.collisionBitmask
        self.notificationBitmask = arguments.notificationBitmask
        self.velocity = arguments.velocity
        self.maxVelocity = arguments.maxVelocity
        self.frameMovementVector = .zero
    }
}
