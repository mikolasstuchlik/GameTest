import CSDL2

enum TTF {
    static func `init`() throws {
        try sdlException(TTF_Init)
    }
}