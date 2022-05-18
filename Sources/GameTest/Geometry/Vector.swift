import Foundation

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

    init(from: Point<Number>, to: Point<Number>) {
        x = to.x - from.x
        y = to.y - from.y
    }
}

extension Vector where Number == Float {
    var degreees: Float {
        let deg = atan2(y, x) * 180 / Float.pi
        return deg < 0 ? deg + 360 : deg 
    }
}

func +<Number: Numeric>(_ lhs: Vector<Number>, _ rhs: Vector<Number>) -> Vector<Number> {
    Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func -<Number: Numeric>(_ lhs: Vector<Number>, _ rhs: Vector<Number>) -> Vector<Number> {
    Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func *<Number: Numeric>(_ lhs: Vector<Number>, _ rhs: Vector<Number>) -> Number {
    lhs.x * rhs.y - lhs.y * rhs.x
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
