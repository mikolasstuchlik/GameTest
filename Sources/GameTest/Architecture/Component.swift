
typealias ComponentIdentifier = Int

protocol OpaqueComponent {
    func destroy()
}

protocol Component: OpaqueComponent {
    associatedtype InitArguments

    /// MUST be unowned(unsafe)
    var entity: Entity? { get set }

    init(entity: Entity, arguments: InitArguments) throws
}

extension Component {
    var isValid: Bool { entity != nil }
}

protocol OpaqueComponentStorage {
    var type: OpaqueComponent.Type { get }
    func destroy(at index: Int) 
}
final class ComponentStorage<C: Component>: OpaqueComponentStorage {
    let type: OpaqueComponent.Type = C.self
    var buffer: [C] = []
    var freedIndicies: [Int] = []


    func allocInit(for entity: Entity, with arguments: C.InitArguments) throws -> Int {
        let new = try C.init(entity: entity, arguments: arguments)
        if let allocated = freedIndicies.popLast() {
            buffer[allocated] = new
            return allocated
        }

        buffer.append(new)
        return buffer.count - 1
    }

    func destroy(at index: Int) {
        buffer[index].destroy()
        buffer[index].entity = nil
        freedIndicies.append(index)
    }
}
