import NoobECS
import NoobECSStores
import CSDL2

struct IntrospectionComponent: Component {
    typealias Store = VectorStorage<Self>

    var color: SDL_Color
    var frameCollidedWith: Set<Entity> = []
    var labelWindowEntity: ObjectIdentifier

    init(
        arguments: (
            color: SDL_Color,
            labelWindowEntity: ObjectIdentifier
        )
    ) {
        self.color = arguments.color
        self.labelWindowEntity = arguments.labelWindowEntity
    }
}