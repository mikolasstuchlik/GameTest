struct InventoryComponent: Component, OpaqueComponentIdentifier {
    typealias Store = EntityPrivateStorage<Self>

    unowned(unsafe) var entity: Entity?

    var bombLimit: UInt8
    var bombDeployed: UInt8
    var flameLength: UInt8

    init(
        entity: Entity, 
        arguments: (
            bombLimit: UInt8,
            bombDeployed: UInt8,
            flameLength: UInt8
        )
    ) {
        self.entity = entity
        self.bombLimit = arguments.bombLimit
        self.bombDeployed = arguments.bombDeployed
        self.flameLength = arguments.flameLength
    }

    func destroy() { }
}
