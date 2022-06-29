protocol Rect {
    associatedtype Number: Numeric

    var minX: Number { get }
    var minY: Number { get }

    var maxX: Number { get }
    var maxY: Number { get }

    var width: Number { get }
    var height: Number { get }

    init(x: Number, y: Number, width: Number, height: Number)
}

extension Rect {
    static var zero: Self { .init(x: .zero, y: .zero, width: .zero, height: .zero) }
}

extension Rect where Number: Comparable {
    func intersects<R: Rect>(with rect: R) -> Bool where Number == R.Number {
        minX < rect.maxX && maxX > rect.minX && minY < rect.maxY && maxY > rect.minY
    }

    func contains(_ point: Point<Number>) -> Bool {
        minX <= point.x && maxX >= point.x && minY <= point.y && maxY >= point.y
    }
}

extension Rect where Number: BinaryFloatingPoint {
    init<R: Rect>(_ other: R) where R.Number: BinaryFloatingPoint {
        self = .init(x: Number(other.minX), y: Number(other.minY), width: Number(other.width), height: Number(other.height))
    }

    init<R: Rect>(_ other: R) where R.Number: BinaryInteger {
        self = .init(x: Number(other.minX), y: Number(other.minY), width: Number(other.width), height: Number(other.height))
    }
}

extension Rect where Number: BinaryInteger {
    init<R: Rect>(_ other: R) where R.Number: BinaryFloatingPoint {
        self = .init(x: Number(other.minX), y: Number(other.minY), width: Number(other.width), height: Number(other.height))
    }

    init<R: Rect>(_ other: R) where R.Number: BinaryInteger {
        self = .init(x: Number(other.minX), y: Number(other.minY), width: Number(other.width), height: Number(other.height))
    }
}
