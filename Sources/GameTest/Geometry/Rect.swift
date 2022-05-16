struct Rect<Number: Numeric>: Equatable {
    var origin: Point<Number>
    var size: Size<Number>

    var x: Number { origin.x }
    var y: Number { origin.y }
    var width: Number { size.width }
    var height: Number { size.height }
}

extension Rect {
    init(x: Number, y: Number, width: Number, height: Number) {
        self.origin = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
}

extension Rect {
    static var zero: Self { .init(origin: .zero, size: .zero) }
}

extension Rect where Number: ExpressibleByFloatLiteral {
    static var zero: Self { .init(origin: .zero, size: .zero) }
}

extension Rect where Number: FloatingPoint {
    var center: Point<Number> { origin + Vector(x: size.width, y: size.height) / 2 }

    init(center: Point<Number>, size: Size<Number>) {
        self.origin = center - Vector(x: size.width, y: size.height) / 2
        self.size = size
    }
}
