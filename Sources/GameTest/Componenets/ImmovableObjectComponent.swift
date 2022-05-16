struct ImmovableObjectComponent: Component {
    static var storage: [Self] = []
    static var freedIndicies: [Int] = []
    static var componentIdentifier = makeIdentifier()

    // this could be unowned(unsafe) reference
    var entity: Entity.Identifier

    var positionCenter: Point<Float>
    var squareRadius: Size<Float>

    var categoryBitmask: UInt32

    init(
        entity: Entity.Identifier, 
        arguments: (
            positionCenter: Point<Float>,
            squareRadius: Size<Float>,
            categoryBitmask: UInt32
        )
    ) {
        self.entity = entity
        self.positionCenter = arguments.positionCenter
        self.squareRadius = arguments.squareRadius
        self.categoryBitmask = arguments.categoryBitmask
    }

    func destroy() { }
}