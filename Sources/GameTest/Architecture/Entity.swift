import Foundation

final class Entity: Hashable {
    typealias Identifier = UInt

    struct ComponentReference {
        let type: OpaqueComponent.Type
        let storage: Int
    }

    static let notAnIdentifier: Identifier = 0

    // Should not be static
    private(set) static var entities = Set<Entity>()
    private(set) var componentReferences: [ComponentReference] = []

    lazy var identifier: Identifier = Identifier(bitPattern: Unmanaged.passUnretained(self).toOpaque())

    init() {
        Entity.entities.insert(self)
    }

    static func == (lhs: Entity, rhs: Entity) -> Bool {
        lhs.identifier == rhs.identifier
    }

    static func unpackUnownedEntity(from identifier: Identifier) -> Entity? {
        UnsafeRawPointer(bitPattern: identifier)
            .flatMap(Unmanaged<Entity>.fromOpaque(_:))?
            .takeUnretainedValue()
    }

    static func clean() {
        entities.removeAll()
    }

    func hash(into hasher: inout Hasher) {
        identifier.hash(into: &hasher)
    }

    func has<C: Component>(component: C.Type) -> Bool {
        componentReferences.contains { $0.type == C.self }
    }

    func assign<C: Component>(component: C.Type, arguments: C.InitArguments) throws {
        if let index = index(of: C.self) {
            let old = componentReferences[index]
            C.storage[old.storage].destroy()
            C.storage[old.storage] = try C.init(entity: identifier, arguments: arguments)
            return
        }

        componentReferences.append(
            ComponentReference(
                type: C.self, 
                storage: try C.allocInit(for: identifier, with: arguments)
            )
        )
    }

    func access<C: Component, R>(component: C.Type, _ accessBlock: (UnsafeMutablePointer<C>?) throws -> R ) rethrows -> R {
        guard let index = index(of: C.self) else {
            return try accessBlock(nil)
        }

        return try withUnsafeMutablePointer(
            to: &C.storage[componentReferences[index].storage], 
            accessBlock
        )
    }

    @discardableResult
    func destroy<C: Component>(component: C.Type) -> Bool {
        guard let index = index(of: C.self) else {
            return false
        }

        let old = componentReferences.remove(at: index)
        old.type.destroy(at: old.storage)
        return true
    }

    private func index<C: Component>(of component: C.Type) -> Int? {
        componentReferences.enumerated().first { $1.type == C.self }?.offset
    }

    deinit {
        componentReferences.forEach { $0.type.destroy(at: $0.storage) }
    }
}