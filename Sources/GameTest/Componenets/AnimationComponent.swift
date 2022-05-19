struct AnimationComponent: Component {
    typealias Store = VectorStorage<Self>

    unowned(unsafe) var entity: Entity?

    var spriteSheet: SpriteSheet.Type
    var startTime: UInt32
    var currentAnimation: String?

    init(
        entity: Entity, 
        arguments: (
            spriteSheet: SpriteSheet.Type,
            startTime: UInt32,
            currentAnimation: String?
        )
    ) {
        self.entity = entity
        self.spriteSheet = arguments.spriteSheet
        self.startTime = arguments.startTime
        self.currentAnimation = arguments.currentAnimation
    }

    func destroy() { }
}