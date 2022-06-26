import NoobECS
import NoobECSStores

struct PlayerComponent: Component {
    typealias Store = EntityPrivateStorage<Self>

    var bombLimit: Int
    var bombDeployed: Int
    var flameLength: Int

    init(
        arguments: (
            bombLimit: Int,
            bombDeployed: Int,
            flameLength: Int
        )
    ) {
        self.bombLimit = arguments.bombLimit
        self.bombDeployed = arguments.bombDeployed
        self.flameLength = arguments.flameLength
    }
}
