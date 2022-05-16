struct ImmovableObjectComponent: Component {
    static var storage: [Self] = []
    static var freedIndicies: [Int] = []

    unowned(unsafe) var entity: Entity?

    var positionCenter: Point<Float>
    var squareRadius: Size<Float>

    var categoryBitmask: UInt32

    init(
        entity: Entity, 
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