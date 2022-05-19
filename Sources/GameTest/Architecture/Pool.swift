class Pool<UpdateContext, RenderContext>: LoopItem, EntityComponentDataManager {
    var systems: [System<UpdateContext, RenderContext>] = []
    var entities: Set<Entity> = []
    var stores: [OpaqueComponentStore] = []

    func update(with context: UpdateContext) throws {
        try systems.forEach { try $0.update(with: context) }
    }

    func render(with context: RenderContext) throws {
        try systems.forEach { try $0.render(with: context) }
    }
}
