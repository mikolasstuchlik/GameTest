import CSDL2
import Foundation

final class Application {
   // private var texture

    init() {
    }

    deinit {
        assert(window == nil)
        assert(renderer == nil)
    }

    func startWindow(title: String, dimension: Rect<CInt>, fullscreen: Bool) throws {
        try sdlException { 
            SDL_Init(SDLBridges.SDL_INIT_EVERTYHING)  
        }
        
        let flags = fullscreen
            ? SDL_WINDOW_FULLSCREEN
            : SDL_WindowFlags(0)

        window = try sdlException {
            SDL_CreateWindow(title, dimension.x , dimension.y, dimension.width, dimension.height, flags.rawValue)
        }

        renderer = try sdlException {
            SDL_CreateRenderer(window, -1, 0)
        }

        let newPool = DefaultPool(application: self)
        newPool.setup()

        replaceCurrentPool(by: newPool)
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
        try! currentPool?.update(with: context)
    }

    func render() throws {
        try! renderer!.renderClear()

        let context = RenderContext()

        measure("rendering") {
            try! currentPool?.render(with: context)
        }

        renderer!.renderPresent()
    }

    func clean() {
        replaceCurrentPool(by: nil)

        SDL_DestroyWindow(window)
        window = nil
        SDL_DestroyRenderer(renderer)
        renderer = nil

        SDL_Quit()
    }

    private func replaceCurrentPool(by newPool: Pool?) {
        #if DEBUG
        weak var pool = currentPool
        #endif

        currentPool = newPool

        #if DEBUG
        assert(pool == nil, "Removed pool should deallocate!")
        #endif
    }

    private(set) var currentPool: Pool?

    private(set) var isRunning: Bool = false

    private(set) var window: SDLWindowPtr!
    private(set) var renderer: SDLRendererPtr!
}
