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

    func contains(_ point: Point<Number>) -> Bool where Number: Comparable {
        origin.x <= point.x 
            && origin.x + size.width >= point.x
            && origin.y <= point.y
            && origin.y + size.height >= point.y
    }
}

extension Rect where Number: BinaryFloatingPoint {
    init<Other: BinaryFloatingPoint>(_ other: Rect<Other>) {
        self.origin = Point<Number>(other.origin)
        self.size = Size<Number>(other.size)
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

    init(center: Point<Number>, radius: Size<Number>) {
        self.origin = center - Vector(x: radius.width, y: radius.height)
        self.size = radius * 2
    }
}

extension Rect {
    func intersects(with rect: Rect) -> Bool where Number: Comparable {
           x            < rect.x + rect.width
        && x + width    > rect.x
        && y            < rect.y + rect.height
        && y + height   > rect.y
    }
}

    
