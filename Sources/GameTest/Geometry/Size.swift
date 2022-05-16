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

func *<Number: Numeric>(_ lhs: Number, _ rhs: Size<Number>) -> Size<Number> {
    Size(width: rhs.width * lhs, height: rhs.height * lhs)
}

func *<Number: Numeric>(_ lhs: Size<Number>, _ rhs: Number) -> Size<Number> {
    Size(width: lhs.width * rhs, height: lhs.height * rhs)
}
