import CSDL2

enum InputEvent {
    case keyDown(SDL_KeyboardEvent)
    case keyUp(SDL_KeyboardEvent)
}

struct UpdateContext {
    let timePassedInMs: UInt32
    let events: [InputEvent]
}

struct RenderContext {

}

protocol LoopItem {
    func update(with context: UpdateContext) throws
    func render(with context: RenderContext) throws
}

protocol System: AnyObject, LoopItem {
    var pool: Pool! { get }
}
