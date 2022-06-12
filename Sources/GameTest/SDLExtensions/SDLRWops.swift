import CSDL2

typealias SDLRWopsPtr = UnsafeMutablePointer<SDL_RWops>

extension SDLRWopsPtr {
    init(file: String, mode: String = "rb") throws {
        self = try sdlException { SDL_RWFromFile(file, mode) }
    }
}