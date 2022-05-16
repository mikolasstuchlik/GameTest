struct MovableObjectComponent: Component {
    static var storage: [Self] = []
    static var freedIndicies: [Int] = []
    static var componentIdentifier = makeIdentifier()

    // this could be unowned(unsafe) reference
    var entity: Entity.Identifier

    var positionCenter: Point<Float>
    var squareRadius: Size<Float> 

    var categoryBitmask: UInt32
    var collisionBitmask: UInt32
    var notificationBitmask: UInt32

    var velocity: Vector<Float>
    var maxVelocity: Float

    init(
        entity: Entity.Identifier, 
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