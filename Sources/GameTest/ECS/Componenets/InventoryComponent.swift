import NoobECS
import NoobECSStores

struct InventoryComponent: Component {
    typealias Store = EntityPrivateStorage<Self>

    var bombLimit: UInt8
    var bombDeployed: UInt8
    var flameLength: UInt8

    init(
        arguments: (
            bombLimit: UInt8,
            bombDeployed: UInt8,
            flameLength: UInt8
        )
    ) {
        self.bombLimit = arguments.bombLimit
        self.bombDeployed = arguments.bombDeployed
        self.flameLength = arguments.flameLength
    }

    func destroy() { }
}
