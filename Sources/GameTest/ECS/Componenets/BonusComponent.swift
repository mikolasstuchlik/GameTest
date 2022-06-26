import NoobECS
import NoobECSStores

struct BonusComponent: Component {
    typealias Store = EntityPrivateStorage<Self>

    var bombLimit: Int
    var flameLength: Int

    init(
        arguments: (
            bombLimit: Int,
            flameLength: Int
        )
    ) {
        self.bombLimit = arguments.bombLimit
        self.flameLength = arguments.flameLength
    }
}
