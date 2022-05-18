import Foundation

enum EntityFactory { }

final class Entity: Hashable {
    struct ComponentReference {
        let type: OpaqueComponent.Type
        var storage: Int
    }

    // Should not be static
    unowned(unsafe) let pool: Pool
    private(set) var componentReferences: [ComponentReference] = []

    var developerLabel: String?

    init(pool: Pool, developerLabel: String? = nil) {
        self.pool = pool
        self.developerLabel = developerLabel
        pool.entities.insert(self)
    }

    static func == (lhs: Entity, rhs: Entity) -> Bool {
        lhs === rhs
    }

    func hash(into hasher: inout Hasher) {
        ObjectIdentifier(self).hash(into: &hasher)
    }

    func has<C: Component>(component: C.Type) -> Bool {
        componentReferences.contains { $0.type == C.self }
    }

    func assign<C: Component>(component: C.Type, arguments: C.InitArguments) throws where C.Categories == Never {
        let storage = pool.storage(for: C.self)
        if let index = index(of: C.self) {
            let old = componentReferences[index]
            storage.buffer[old.storage].destroy()
            storage.buffer[old.storage] = try C.init(entity: self, arguments: arguments)
            return
        }

        componentReferences.append(
            ComponentReference(
                type: C.self, 
                storage: try storage.allocInit(for: self, with: arguments)
            )
        )
    }

    func assign<C: Component>(component: C.Type, category: C.Categories, arguments: C.InitArguments) throws {
        let storage = pool.storage(for: C.self)

        let oldIndex = index(of: C.self)
        destroy(component: C.self)
        let newIndex = try storage.allocInit(for: self, category: category, with: arguments)

        if let oldIndex = oldIndex {
            componentReferences[oldIndex].storage = newIndex
        } else {
            componentReferences.append(ComponentReference(type: C.self, storage: newIndex))
        }
    }

    func access<C: Component, R>(component: C.Type, accessBlock: (inout C) throws -> R ) rethrows -> R? {
        guard let index = index(of: C.self) else {
            return nil
        }

        return try accessBlock(&pool.storage(for: C.self).buffer[componentReferences[index].storage])
    }

    @discardableResult
    func destroy<C: Component>(component: C.Type) -> Bool {
        guard let index = index(of: C.self) else {
            return false
        }

        let old = componentReferences.remove(at: index)
        pool.storage(for: C.self).destroy(at: old.storage)
        return true
    }

    func relocated<C: Component>(component: C.Type, to newIndex: Int) {
        guard let index = index(of: C.self) else {
            return
        }

        componentReferences[index].storage = newIndex
    }

    private func index<C: Component>(of component: C.Type) -> Int? {
        componentReferences.enumerated().first { $1.type == C.self }?.offset
    }

    deinit {
        componentReferences.forEach { 
            pool.destroy(opaque: $0.type, at: $0.storage)
        }
    }
}