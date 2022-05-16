
struct Point<Number: Numeric>: Equatable {
    var x: Number
    var y: Number
}

extension Point {
    static var zero: Self { .init(x: 0, y: 0) }
}

extension Point where Number: ExpressibleByFloatLiteral {
    static var zero: Self { .init(x: 0, y: 0) }
}

func +<Number: Numeric>(_ lhs: Point<Number>, _ rhs: Point<Number>) -> Point<Number> {
    Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func -<Number: Numeric>(_ lhs: Point<Number>, _ rhs: Point<Number>) -> Point<Number> {
    Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func +<Number: Numeric>(_ lhs: Vector<Number>, _ rhs: Point<Number>) -> Point<Number> {
    Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func +<Number: Numeric>(_ lhs: Point<Number>, _ rhs: Vector<Number>) -> Point<Number> {
    Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func -<Number: Numeric>(_ lhs: Point<Number>, _ rhs: Vector<Number>) -> Point<Number> {
    Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}
