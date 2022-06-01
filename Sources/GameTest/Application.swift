import CSDL2
import Foundation

final class Application {
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

        try sdlException {
            TTF_Init()
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

        let newPool = DefaultPool {[weak self] in self?.renderer }
        newPool.setup()

        replaceCurrentPool(by: newPool)
        isRunning = true
    }

    func handleEvents() -> [InputEvent] { 
        var result: [InputEvent] = []
        var event = SDL_Event()
        while withUnsafeMutablePointer(to: &event, SDL_PollEvent(_:)) == 1 {
            switch SDL_EventType(event.type) {
            case SDL_QUIT:
                isRunning = false
            case SDL_KEYDOWN:
                result.append(.keyDown(event.key))
            case SDL_KEYUP:
                result.append(.keyUp(event.key))
            default:
                break
            }
        }

        return result
    }

    func update(currentTime: UInt32, timePassedInMs: UInt32, events: [InputEvent]) { 
        let context = SDLUpdateContext(
            currentTime: currentTime,
            timePassedInMs: timePassedInMs,
            events: events
        )
        try! currentPool?.update(with: context)
    }

    func render() throws {
        try! renderer!.renderClear()

        measure("rendering") {
            for layer in Layer.allCases  {
                let context = SDLRenderContext(renderer: renderer!, currentLayer: layer)
                try! currentPool?.render(with: context)
            }
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

    private func replaceCurrentPool(by newPool: SDLPool?) {
        #if DEBUG
        weak var pool = currentPool
        #endif

        currentPool = newPool

        #if DEBUG
        assert(pool == nil, "Removed pool should deallocate!")
        #endif
    }

    private(set) var currentPool: SDLPool?

    private(set) var isRunning: Bool = false

    private(set) var window: SDLWindowPtr!
    private(set) var renderer: SDLRendererPtr!
}
