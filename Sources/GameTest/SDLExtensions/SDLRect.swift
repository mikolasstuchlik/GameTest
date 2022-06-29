import CSDL2

extension SDL_Rect {
    init<R: Rect>(_ rect: R) where R.Number: BinaryFloatingPoint {
        self.init(
            x: CInt(rect.minX), 
            y: CInt(rect.minY), 
            w: CInt(rect.width), 
            h: CInt(rect.height)
        )
    }

    init<R: Rect>(_ rect: R) where R.Number: BinaryInteger {
        self.init(
            x: CInt(rect.minX), 
            y: CInt(rect.minY), 
            w: CInt(rect.width), 
            h: CInt(rect.height)
        )
    }

    static var zero: Self { .init(x: 0, y: 0, w: 0, h: 0) }
}
