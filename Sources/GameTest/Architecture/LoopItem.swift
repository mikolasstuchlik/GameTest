protocol LoopItem {
    associatedtype UpdateContext
    associatedtype RenderContext

    func update(with context: UpdateContext) throws
    func render(with context: RenderContext) throws
}
