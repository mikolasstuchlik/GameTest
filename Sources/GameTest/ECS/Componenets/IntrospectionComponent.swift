import NoobECS
import NoobECSStores
import CSDL2

struct IntrospectionComponent: Component {
    typealias Store = VectorStorage<Self>

    var color: SDL_Color
    var frameCollidedWith: Set<Entity> = []

    init(
        arguments: SDL_Color
    ) {
        self.color = arguments
    }
}