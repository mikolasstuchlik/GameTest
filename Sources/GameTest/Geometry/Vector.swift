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

extension Vector where Number: BinaryFloatingPoint {
    var magnitude: Number { 
        sqrt(x * x + y * y)
    }
}

extension Vector where Number: BinaryFloatingPoint {
    init<Other: BinaryFloatingPoint>(_ other: Vector<Other>) {
        self.x = Number(other.x)
        self.y = Number(other.y)
    }
}

extension Vector where Number == Float {
    var degreees: Float {
        let deg = atan2(y, x) * 180 / Float.pi
        return deg < 0 ? deg + 360 : deg 
    }
}

extension Vector where Number == Double {
    var degreees: Double {
        let deg = atan2(y, x) * 180 / Double.pi
        return deg < 0 ? deg + 360 : deg 
    }
}

func +<Number: Numeric>(_ lhs: Vector<Number>, _ rhs: Vector<Number>) -> Vector<Number> {
    Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func -<Number: Numeric>(_ lhs: Vector<Number>, _ rhs: Vector<Number>) -> Vector<Number> {
    Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

precedencegroup ConstructorPrecedence {
    associativity: none
    higherThan: MultiplicationPrecedence
}
infix operator →: ConstructorPrecedence
func →<Number: Numeric>(_ lhs: Point<Number>, _ rhs: Point<Number>) -> Vector<Number> {
    Vector(x: rhs.x - lhs.x, y: rhs.y - lhs.y)
}

prefix operator ⟂
prefix func ⟂<Number: Numeric>(_ vect: Vector<Number>) -> Vector<Number> {
    Vector(x: vect.y, y: vect.x * (-1 as Number))
}

infix operator ⨯: MultiplicationPrecedence
/// Vector "corss product"
func ⨯<Number: Numeric>(_ lhs: Vector<Number>, _ rhs: Vector<Number>) -> Number {
    lhs.x * rhs.y - lhs.y * rhs.x
}

infix operator ⊙: MultiplicationPrecedence
/// Vector "dot product"
func ⊙<Number: Numeric>(_ lhs: Vector<Number>, _ rhs: Vector<Number>) -> Number {
    lhs.x * rhs.x + lhs.y * rhs.y
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
