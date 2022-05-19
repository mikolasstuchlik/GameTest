struct PhysicalObjectComponent: CategoryComponent {
    typealias Store = CategoryVectorStorage<Self>
    enum Categories: ComponentCategory {
        case movable, immovable, immaterial
    }

    static let placeholder = PhysicalObjectComponent.init(entity: nil, startingPosition: .zero, positionCenter: .zero, squareRadius: .zero, categoryBitmask: 0, collisionBitmask: 0, notificationBitmask: 0, velocity: .zero, maxVelocity: 0)

    unowned(unsafe) var entity: Entity?

    var startingPosition: Point<Float>
    var positionCenter: Point<Float>
    var squareRadius: Size<Float> 

    var categoryBitmask: UInt32
    var collisionBitmask: UInt32
    var notificationBitmask: UInt32

    var velocity: Vector<Float>
    var maxVelocity: Float

    func destroy() { }
}

extension PhysicalObjectComponent {
    init(
        entity: Entity, 
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
        self.entity = entity
        self.startingPosition = arguments.positionCenter
        self.positionCenter = arguments.positionCenter
        self.squareRadius = arguments.squareRadius
        self.categoryBitmask = arguments.categoryBitmask
        self.collisionBitmask = arguments.collisionBitmask
        self.notificationBitmask = arguments.notificationBitmask
        self.velocity = arguments.velocity
        self.maxVelocity = arguments.maxVelocity
    }

}