import Foundation

struct Size<Number: Numeric>: Equatable {
    var width: Number
    var height: Number 
}

extension Size {
    static var zero: Self { .init(width: 0, height: 0) }
}

extension Size where Number: ExpressibleByFloatLiteral {
    static var zero: Self { .init(width: 0, height: 0) }
}

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

struct Vector<Number: Numeric>: Equatable {
    var x: Number
    var y: Number
}

extension Vector {
    static var zero: Self { .init(x: 0, y: 0) }
}

extension Vector where Number: ExpressibleByFloatLiteral {
    static var zero: Self { .init(x: 0, y: 0) }
}

extension Vector where Number: FloatingPoint {
    var magnitude: Number { 
        sqrt(x * x + y * y)
    }
}

func +<Number: Numeric>(_ lhs: Point<Number>, _ rhs: Point<Number>) -> Point<Number> {
    Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func -<Number: Numeric>(_ lhs: Point<Number>, _ rhs: Point<Number>) -> Point<Number> {
    Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func +<Number: Numeric>(_ lhs: Vector<Number>, _ rhs: Vector<Number>) -> Vector<Number> {
    Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func -<Number: Numeric>(_ lhs: Vector<Number>, _ rhs: Vector<Number>) -> Vector<Number> {
    Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func *<Number: Numeric>(_ lhs: Number, _ rhs: Vector<Number>) -> Vector<Number> {
    Vector(x: rhs.x * lhs, y: rhs.y * lhs)
}

func *<Number: Numeric>(_ lhs: Vector<Number>, _ rhs: Number) -> Vector<Number> {
    Vector(x: lhs.x * rhs, y: lhs.y * rhs)
}

func /<Number: FloatingPoint>(_ lhs: Vector<Number>, _ rhs: Number) -> Vector<Number> {
    Vector(x: lhs.x / rhs, y: lhs.y / rhs)
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