import NoobECS
import NoobECSStores

struct PhysicalObjectComponent: CategoryComponent {
    typealias Store = CategoryVectorStorage<Self>
    enum Categories: NoobECSStores.Category {
        case movable, immovable, immaterial
    }

    var startingPosition: Point<Float>
    var positionCenter: Point<Float>
    var squareRadius: Size<Float> 

    var categoryBitmask: UInt32
    var collisionBitmask: UInt32
    var notificationBitmask: UInt32

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
        self.startingPosition = arguments.positionCenter
        self.positionCenter = arguments.positionCenter
        self.squareRadius = arguments.squareRadius
        self.categoryBitmask = arguments.categoryBitmask
        self.collisionBitmask = arguments.collisionBitmask
        self.notificationBitmask = arguments.notificationBitmask
        self.velocity = arguments.velocity
        self.maxVelocity = arguments.maxVelocity
    }


    func destroy() { }
}
