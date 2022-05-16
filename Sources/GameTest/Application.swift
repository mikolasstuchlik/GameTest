import CLibs
import Foundation

final class Application {
   // private var texture

    init() {
    }

    deinit {
        assert(Application.window == nil)
        assert(Application.renderer == nil)
    }

    func startWindow(title: String, dimension: Rect<CInt>, fullscreen: Bool) throws {
        try sdlException { 
            SDL_Init(SDLBridges.SDL_INIT_EVERTYHING)  
        }
        
        let flags = fullscreen
            ? SDL_WINDOW_FULLSCREEN
            : SDL_WindowFlags(0)

        Application.window = try sdlException {
            SDL_CreateWindow(title, dimension.x , dimension.y, dimension.width, dimension.height, flags.rawValue)
        }

        Application.renderer = try sdlException {
            SDL_CreateRenderer(Application.window, -1, 0)
        }

        systems = [
            MovementSystem(),
            UserInputSystem(),
            RenderSystem(renderer: Application.renderer),
        ]

        isRunning = true
    }

    func handleEvents() -> EnputEvents { 
        var event = SDL_Event()
        let eventPending = withUnsafeMutablePointer(to: &event, SDL_PollEvent(_:)) == 1
            ? true
            : false

        guard eventPending else { return .none }

        switch SDL_EventType(event.type) {
        case SDL_QUIT:
            isRunning = false
        case SDL_KEYDOWN:
            return .keyDown(event.key)
        case SDL_KEYUP:
            return .keyUp(event.key)
        default:
            break
        }

        return .none
    }

    func update(events: EnputEvents) { 
        let context = UpdateContext(events: events)
        systems.forEach { try! $0.update(with: context) }
    }

    func render() throws {
        try! Application.renderer!.renderClear()

        let context = RenderContext()

        systems.forEach { try! $0.render(with: context) }

        Application.renderer!.renderPresent()
    }

    func clean() {
        Entity.clean()
        systems.removeAll()

        SDL_DestroyWindow(Application.window)
        Application.window = nil
        SDL_DestroyRenderer(Application.renderer)
        Application.renderer = nil

        SDL_Quit()
    }

    private(set) var systems: [System] = []
    private(set) var isRunning: Bool = false

    private(set) static var window: SDLWindowPtr?
    private(set) static var renderer: SDLRendererPtr?
}