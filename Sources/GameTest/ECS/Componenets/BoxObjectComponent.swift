import NoobECS
import NoobECSStores

struct BoxObjectComponent: CategoryComponent {
    typealias Store = CategoryVectorStorage<Self>
    enum Categories: NoobECSStores.Category {
        case movable, immovable, immaterial
    }

    var positionCenter: Point<Float>
    var squareRadius: Size<Float> 

    var categoryBitmask: UInt32
    var collisionBitmask: UInt32
    var notificationBitmask: UInt32

    var frameMovementVector: Vector<Float>
    var velocity: Vector<Float>
    var maxVelocity: Float

     init(
        arguments: (
            positionCenter: Point<Float>,
            squareRadius: Size<Float>,
            categoryBitmask: UInt32,
            collisionBitmask: UInt32,
            notificationBitmask: UInt32,
            velocity: Vector<Float>,
            maxVelocity: Float
        )
    ) {
        self.positionCenter = arguments.positionCenter
        self.squareRadius = arguments.squareRadius
        self.categoryBitmask = arguments.categoryBitmask
        self.collisionBitmask = arguments.collisionBitmask
        self.notificationBitmask = arguments.notificationBitmask
        self.velocity = arguments.velocity
        self.maxVelocity = arguments.maxVelocity
        self.frameMovementVector = .zero
    }
}
