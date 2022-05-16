protocol Pool: AnyObject, LoopItem {
    var application: Application { get }
    var systems: [System] { get }
    var entities: Set<Entity> { get set }
    var textureBuffer: TextureBuffer { get }
    
    func storage<C: Component>(for component: C.Type) -> ComponentStorage<C>
    func destroy(opaque component: OpaqueComponent.Type, at index: Int)
}

class BasePool: Pool {
    let application: Application
    var systems: [System] = []
    var entities: Set<Entity> = []
    var stores: [OpaqueComponentStorage] = []
    private(set) lazy var textureBuffer: TextureBuffer = TextureBuffer(pool: self)

    init(application: Application) {
        self.application = application
    }
    
    func storage<C: Component>(for component: C.Type) -> ComponentStorage<C> {
        for store in stores where store is ComponentStorage<C> {
            return store as! ComponentStorage<C>
        }
        let new = ComponentStorage<C>()
        stores.append(new)
        return new
    }

    func destroy(opaque component: OpaqueComponent.Type, at index: Int) {
        for store in stores where store.type == component {
            store.destroy(at: index)
        }
    }

    func update(with context: UpdateContext) throws {
        try systems.forEach { try $0.update(with: context) }
    }

    func render(with context: RenderContext) throws {
        try systems.forEach { try $0.render(with: context) }
    }
}
