
typealias ComponentIdentifier = Int

protocol OpaqueComponent {
    static func destroy(at index: Int)
    func destroy()
}

// TODO: Implement (smart) defragmentation

protocol Component: OpaqueComponent {
    associatedtype InitArguments

    static var storage: [Self] { get set }
    static var freedIndicies: [Int] { get set }

    static func allocInit(for entity: Entity, with arguments: InitArguments) throws -> Int

    /// MUST be unowned(unsafe)
    var entity: Entity? { get set }

    init(entity: Entity, arguments: InitArguments) throws
}

extension Component {
    var isValid: Bool { entity != nil }

    static func allocInit(for entity: Entity, with arguments: InitArguments) throws -> Int {
        let new = try Self.init(entity: entity, arguments: arguments)
        if let allocated = freedIndicies.popLast() {
            storage[allocated] = new
            return allocated
        }

        storage.append(new)
        return storage.count - 1
    }

    static func destroy(at index: Int) {
        storage[index].destroy()
        storage[index].entity = nil
        freedIndicies.append(index)
    }
}
