import CLibs

enum SDLError: Error {
    case sdlError(message: String)
}

func sdlException<T>(_ block: () -> UnsafeMutablePointer<T>?) throws -> UnsafeMutablePointer<T> {
     guard let result = block() else {
        let message = String(cString: SDL_GetError())
        SDL_ClearError()
        throw SDLError.sdlError(message: message)
    } 
    return result
}

func sdlException(_ block: () -> CInt ) throws {
    guard block() == 0 else {
        let message = String(cString: SDL_GetError())
        SDL_ClearError()
        throw SDLError.sdlError(message: message)
    }
}