final class EntityPrivateStorage<C: Component & OpaqueComponentIdentifier>: ComponentStore {
    typealias StoreOptions = Void
    typealias ComponentIdentifier = C
    typealias StoredComponent = C

    let type: OpaqueComponent.Type = C.self
}
