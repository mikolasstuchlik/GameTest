protocol OpaqueComponent {
    func destroy()
}

protocol OpaqueComponentIdentifier { }

protocol OpaqueComponentStore {
    var type: OpaqueComponent.Type { get }
    func destroy(at index: OpaqueComponentIdentifier) 
}
protocol ComponentStore: OpaqueComponentStore {
    associatedtype StoreOptions
    associatedtype ComponentIdentifier: OpaqueComponentIdentifier
    associatedtype StoredComponent: Component

    init()
    func allocInit(for entity: Entity, options: StoreOptions, with arguments: StoredComponent.InitArguments) throws -> ComponentIdentifier
    func destroy(at identifier: ComponentIdentifier)
    func access<R>(at identifier: inout OpaqueComponentIdentifier, validityScope: (inout StoredComponent) throws -> R) rethrows -> R?
}

extension ComponentStore where ComponentIdentifier == StoredComponent {
    func access<R>(at identifier: inout OpaqueComponentIdentifier, validityScope: (inout StoredComponent) throws -> R) rethrows -> R? {
        var typedCopy = identifier as! StoredComponent
        defer { identifier = typedCopy }
        return try validityScope(&typedCopy)
    }

    func destroy(at index: ComponentIdentifier) {
        index.destroy()
    }

    func allocInit(for entity: Entity, options: StoreOptions, with arguments: StoredComponent.InitArguments) throws -> ComponentIdentifier {
        try StoredComponent.init(entity: entity, arguments: arguments)
    }
}

extension ComponentStore where StoreOptions == Void {
    func allocInit(for entity: Entity, with arguments: StoredComponent.InitArguments) throws -> ComponentIdentifier {
        try allocInit(for: entity, options: (), with: arguments)
    }
}

extension ComponentStore {
    func destroy(at index: OpaqueComponentIdentifier) {
        destroy(at: index as! ComponentIdentifier)
    }
}

protocol Component: OpaqueComponent {
    associatedtype InitArguments
    associatedtype Store: ComponentStore

    /// MUST be unowned(unsafe)
    var entity: Entity? { get set }

    init(entity: Entity, arguments: InitArguments) throws
}

extension Component {
    var isValid: Bool { entity != nil }
}
