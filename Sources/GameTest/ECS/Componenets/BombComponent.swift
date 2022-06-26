import NoobECS
import NoobECSStores

struct BombComponent: Component {
    typealias Store = EntityPrivateStorage<Self>

    var flameLength: Int
    var summoningPlayer: ObjectIdentifier

    init(
        arguments: (
            flameLength: Int,
            summoningPlayer: ObjectIdentifier
        )
    ) {
        self.flameLength = arguments.flameLength
        self.summoningPlayer = arguments.summoningPlayer
    }
}
