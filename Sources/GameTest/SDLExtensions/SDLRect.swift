import CLibs

extension SDL_Rect {
    init<T: SignedInteger>(_ rect: Rect<T>) {
        self.init(
            x: CInt(rect.x), 
            y: CInt(rect.y), 
            w: CInt(rect.width), 
            h: CInt(rect.height)
        )
    }

    init<T: BinaryFloatingPoint>(_ rect: Rect<T>) {
        self.init(
            x: CInt(rect.x), 
            y: CInt(rect.y), 
            w: CInt(rect.width), 
            h: CInt(rect.height)
        )
    }

    static var zero: Self { .init(x: 0, y: 0, w: 0, h: 0) }
}
