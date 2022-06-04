import CSDL2

extension SDL_Color {
    static let black = SDL_Color(r: 0, g: 0, b: 0, a: 255)
    static let white = SDL_Color(r: 255, g: 255, b: 255, a: 255)
    static let red = SDL_Color(r: 255, g: 0, b: 0, a: 255)
    static let green = SDL_Color(r: 0, g: 255, b: 0, a: 255)
    static let blue = SDL_Color(r: 0, g: 0, b: 255, a: 255)
    static let yellow = SDL_Color(r: 255, g: 255, b: 0, a: 255)
    static let pink = SDL_Color(r: 255, g: 0, b: 255, a: 255)
    static let cyan = SDL_Color(r: 0, g: 255, b: 255, a: 255)

    static let colors: [SDL_Color] = [
        black, white, red, green, blue, yellow, pink, cyan
    ]
}

extension SDL_Color: Equatable {
    public static func == (lhs: SDL_Color, rhs: SDL_Color) -> Bool {
        lhs.r == rhs.r
            && lhs.g == rhs.g
            && lhs.b == rhs.b
            && lhs.a == rhs.a
    }
}
