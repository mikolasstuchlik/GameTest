import Foundation

enum EntityFactory { }

final class Entity: Hashable {
    struct ComponentReference {
        let type: OpaqueComponent.Type
        let storage: Int
    }

    // Should not be static
    private(set) static var entities = Set<Entity>()
    private(set) var componentReferences: [ComponentReference] = []

    var developerLabel: String?

    init(developerLabel: String? = nil) {
        self.developerLabel = developerLabel
        Entity.entities.insert(self)
    }

    static func == (lhs: Entity, rhs: Entity) -> Bool {
        lhs === rhs
    }

    static func clean() {
        entities.removeAll()
    }

    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }

    func has<C: Component>(component: C.Type) -> Bool {
        componentReferences.contains { $0.type == C.self }
    }

    func assign<C: Component>(component: C.Type, arguments: C.InitArguments) throws {
        if let index = index(of: C.self) {
            let old = componentReferences[index]
            C.storage[old.storage].destroy()
            C.storage[old.storage] = try C.init(entity: self, arguments: arguments)
            return
        }

        componentReferences.append(
            ComponentReference(
                type: C.self, 
                storage: try C.allocInit(for: self, with: arguments)
            )
        )
    }

    func access<C: Component, R>(component: C.Type, _ accessBlock: (inout C) throws -> R ) rethrows -> R? {
        guard let index = index(of: C.self) else {
            return nil
        }

        return try accessBlock(&C.storage[componentReferences[index].storage])
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