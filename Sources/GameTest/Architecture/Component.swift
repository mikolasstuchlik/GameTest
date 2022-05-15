
typealias ComponentIdentifier = Int

protocol OpaqueComponent {
    static func destroy(at index: Int)
    static var componentIdentifier: ComponentIdentifier { get }
    func destroy()
}

// TODO: Implement (smart) defragmentation

protocol Component: OpaqueComponent {
    associatedtype InitArguments

    static var storage: [Self] { get set }
    static var freedIndicies: [Int] { get set }

    static func allocInit(for entity: Entity.Identifier, with arguments: InitArguments) throws -> Int

    var entity: Entity.Identifier { get set }

    init(entity: Entity.Identifier, arguments: InitArguments) throws
}

extension Component {
    static func makeIdentifier() -> ComponentIdentifier {
        String(describing: Self.self).hash
    }

    static func allocInit(for entity: Entity.Identifier, with arguments: InitArguments) throws -> Int {
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
        storage[index].entity = Entity.notAnIdentifier
        freedIndicies.append(index)
    }
}
