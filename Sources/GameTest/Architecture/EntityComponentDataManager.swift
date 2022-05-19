protocol EntityComponentDataManager: AnyObject {
    var entities: Set<Entity> { get set }
    var stores: [OpaqueComponentStore] { get set }

    func storage<C: Component>(for component: C.Type) -> C.Store
    func destroy(opaque component: OpaqueComponent.Type, at index: OpaqueComponentIdentifier)
}

extension EntityComponentDataManager {
    func storage<C: Component>(for component: C.Type) -> C.Store {
        for store in stores where store is C.Store {
            return store as! C.Store
        }
        let new = C.Store()
        stores.append(new)
        return new
    }

    func destroy(opaque component: OpaqueComponent.Type, at index: OpaqueComponentIdentifier) {
        for store in stores where store.type == component {
            store.destroy(at: index)
        }
    }
}
