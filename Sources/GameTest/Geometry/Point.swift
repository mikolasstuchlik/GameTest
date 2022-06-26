import Foundation

struct Point<Number: Numeric>: Equatable {
    var x: Number
    var y: Number
}

extension Point {
    static var zero: Self { .init(x: 0, y: 0) }
}

extension Point where Number: BinaryFloatingPoint {
    init<Other: BinaryFloatingPoint>(_ other: Point<Other>) {
        self.x = Number(other.x)
        self.y = Number(other.y)
    }

    func distance(to point: Point) -> Number {
        sqrt( (x - point.x) * (x - point.x) + (y - point.y) * (y - point.y))
    }
}

extension Point where Number == Float {
    /// https://danceswithcode.net/engineeringnotes/rotations_in_2d/rotations_in_2d.html
    func rotated(around center: Point<Number>, angle: Number) -> Self {
        Point(
            x: (x - center.x) * cos(angle) - (y - center.y) * sin(angle) + center.x,
            y: (x - center.x) * sin(angle) + (y - center.y) * cos(angle) + center.y
        )
    }
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
