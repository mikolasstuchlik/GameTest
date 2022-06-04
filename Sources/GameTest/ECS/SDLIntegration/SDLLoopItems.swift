import NoobECS

import CSDL2

enum InputEvent {
    case keyDown(SDL_KeyboardEvent)
    case keyUp(SDL_KeyboardEvent)
    case mouseKeyDown(SDL_MouseButtonEvent)
}

struct SDLUpdateContext {
    let currentTime: UInt32
    let timePassedInMs: UInt32
    let events: [InputEvent]
}

struct SDLRenderContext {
    let renderer: SDLRendererPtr
    let currentLayer: Layer
}

struct PassedTimeCount {
    private var lastTickInMs: UInt32 = 0

    mutating func nextFrame() -> (current: UInt32, delta: UInt32) {
        let currentTickInMs = SDL_GetTicks()
        let ticksInMsDelta = currentTickInMs - lastTickInMs
        lastTickInMs = currentTickInMs
        return (currentTickInMs, ticksInMsDelta)
    }
}

struct FrameCapCount {
    static let nMiliSecsInSec: UInt32 = 1000

    let frameCap: UInt32
    let frameDelay: UInt32

    init(frameCap: UInt32) {
        self.frameCap = frameCap
        self.frameDelay = FrameCapCount.nMiliSecsInSec / frameCap
    }

    func delayAfter(_ block: () -> Void) {
        let frameStart = SDL_GetTicks()
        block()
        let frameTime = SDL_GetTicks() - frameStart
        report(name: "Frame time", measured: "\(frameTime) ms")
        if frameDelay > frameTime {
            SDL_Delay(frameDelay - frameTime)
        }
    }
}
