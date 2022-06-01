import NoobECS
import NoobECSStores

struct AnimationComponent: Component {
    typealias Store = VectorStorage<Self>

    var spriteSheet: SpriteSheet.Type
    var startTime: UInt32
    var currentAnimation: String?

    init(
        arguments: (
            spriteSheet: SpriteSheet.Type,
            startTime: UInt32,
            currentAnimation: String?
        )
    ) {
        self.spriteSheet = arguments.spriteSheet
        self.startTime = arguments.startTime
        self.currentAnimation = arguments.currentAnimation
    }
}