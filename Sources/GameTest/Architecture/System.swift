import CSDL2

enum EnputEvents {
    case none
    case keyDown(SDL_KeyboardEvent)
    case keyUp(SDL_KeyboardEvent)
}

struct UpdateContext {
    let events: EnputEvents
}

struct RenderContext {

}

protocol LoopItem {
    func update(with context: UpdateContext) throws
    func render(with context: RenderContext) throws
}

protocol System: AnyObject, LoopItem {
    var pool: Pool { get }
}
