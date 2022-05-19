class System<UpdateContext, RenderContext>: LoopItem {
    weak var pool: Pool<UpdateContext, RenderContext>!

    init(pool: Pool<UpdateContext, RenderContext>) {
        self.pool = pool
    }

    func update(with context: UpdateContext) throws {
    }

    func render(with context: RenderContext) throws {
    }
}
