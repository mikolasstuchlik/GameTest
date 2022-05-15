struct MovementComponent: Component {
    static var storage: [Self] = []
    static var freedIndicies: [Int] = []
    static var componentIdentifier = makeIdentifier()

    // this could be unowned(unsafe) reference
    var entity: Entity.Identifier
    var position: Point<Float>
    var velocity: Vector<Float>
    var maxVelocity: Float

    init(
        entity: Entity.Identifier, 
        arguments: (
            position: Point<Float>,
            velocity: Vector<Float>,
            maxVelocity: Float
        )
    ) {
        self.entity = entity
        self.position = arguments.position
        self.velocity = arguments.velocity
        self.maxVelocity = arguments.maxVelocity
    }

    func destroy() { }
}