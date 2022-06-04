import CSDL2

typealias SDLRendererPtr = UnsafeMutablePointer<SDL_Renderer>

extension SDLRendererPtr {
    func render(_ texture: SDLTexturePtr, source: SDL_Rect?, destination: SDL_Rect) throws {
        try sdlException {
            withUnsafePointer(to: destination) { destination in
                if let source = source {
                    return withUnsafePointer(to: source) { source in
                        SDL_RenderCopy(self, texture, source, destination)
                    }   
                }

                return SDL_RenderCopy(self, texture, nil, destination)
            }
        }
    }

    func setDrawColor(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) throws {
        try sdlException {
            SDL_SetRenderDrawColor(self, red, green, blue, alpha)
        }
    }

    func setDraw(color: SDL_Color) throws {
        try sdlException {
            SDL_SetRenderDrawColor(self, color.r, color.g, color.b, color.a)
        }
    }

    func draw(rect: SDL_Rect) throws {
        var rect = rect
        try sdlException { SDL_RenderDrawRect(self, &rect) }
    }

    func draw(line: Line<Float>) throws {
        try sdlException {
            SDL_RenderDrawLine(
                self, 
                CInt(line.origin.x),
                CInt(line.origin.y),
                CInt((line.origin + line.vector).x),
                CInt((line.origin + line.vector).y)
            )
        }
    }

    func renderClear() throws {
        try sdlException {
            SDL_RenderClear(self) 
        }
    }

    func renderPresent() {
        SDL_RenderPresent(self)
    }

    func createTextureFromSurface(from surface: SDLSurfacePtr) throws -> SDLTexturePtr {
        try sdlException {
            SDL_CreateTextureFromSurface(self, surface)
        }
    }
}
