import CSDL2

enum SDL {
    static let SDL_INIT_EVERTYHING: UInt32 = SDL_INIT_TIMER | SDL_INIT_AUDIO | SDL_INIT_VIDEO | SDL_INIT_EVENTS | SDL_INIT_JOYSTICK | SDL_INIT_HAPTIC | SDL_INIT_GAMECONTROLLER | SDL_INIT_SENSOR

    static func `init`(flags: UInt32) throws {
        try sdlException { SDL_Init(flags) }
    }
}

