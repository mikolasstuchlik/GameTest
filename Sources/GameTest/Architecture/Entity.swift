import Foundation

enum EntityFactory { }

final class Entity: Hashable {
    struct ComponentReference {
        let type: OpaqueComponent.Type
        var storage: OpaqueComponentIdentifier
    }

    unowned(unsafe) let dataManager: EntityComponentDataManager
    private(set) var componentReferences: [ComponentReference] = []

    var developerLabel: String?

    init(dataManager: EntityComponentDataManager, developerLabel: String? = nil) {
        self.dataManager = dataManager
        self.developerLabel = developerLabel
        dataManager.entities.insert(self)
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

    func assign<C: Component>(component: C.Type, arguments: C.Store.StoredComponent.InitArguments) throws where C.Store.StoreOptions == Void {
        try assign(component: C.self, options: (), arguments: arguments)
    }

    func assign<C: Component>(component: C.Type, options: C.Store.StoreOptions, arguments: C.Store.StoredComponent.InitArguments) throws {
        let storage = dataManager.storage(for: C.self)

        let oldIndex = index(of: C.self)
        destroy(component: C.self)
        let newIndex = try storage.allocInit(for: self, options: options, with: arguments)

        if let oldIndex = oldIndex {
            componentReferences[oldIndex].storage = newIndex
        } else {
            componentReferences.append(ComponentReference(type: C.self, storage: newIndex))
        }
    }

    func access<C: Component, R>(component: C.Type, accessBlock: (inout C.Store.StoredComponent) throws -> R ) rethrows -> R? {
        guard let index = index(of: C.self) else {
            return nil
        }

        return try dataManager.storage(for: C.self).access(at: &componentReferences[index].storage, validityScope: accessBlock)
    }

    @discardableResult
    func destroy<C: Component>(component: C.Type) -> Bool {
        guard let index = index(of: C.self) else {
            return false
        }

        let old = componentReferences.remove(at: index)
        dataManager.storage(for: C.self).destroy(at: old.storage)
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
            dataManager.destroy(opaque: $0.type, at: $0.storage)
        }
    }
}