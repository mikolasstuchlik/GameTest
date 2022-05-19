extension Int: OpaqueComponentIdentifier {}

final class VectorStorage<C: Component>: ComponentStore {
    typealias StoreOptions = Void
    typealias ComponentIdentifier = Int
    typealias StoredComponent = C

    let type: OpaqueComponent.Type = C.self
    var buffer: [C] = []

    private(set) var freedIndicies: [Int] = []

    func allocInit(for entity: Entity, options: StoreOptions, with arguments: StoredComponent.InitArguments) throws -> ComponentIdentifier {
        let new = try C.init(entity: entity, arguments: arguments)

        if let allocated = freedIndicies.popLast() {
            buffer[allocated] = new
            return allocated
        }

        buffer.append(new)
        return buffer.count - 1
    }

    func access<R>(at identifier: inout OpaqueComponentIdentifier, validityScope: (inout StoredComponent) throws -> R) rethrows -> R? {
        try validityScope(&buffer[identifier as! ComponentIdentifier])
    }

    func destroy(at index: Int) {
        freedIndicies.append(index)
        buffer[index].destroy()
        buffer[index].entity = nil
    }
}