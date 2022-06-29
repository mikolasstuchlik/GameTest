struct AxisRect<Number: Numeric>: Equatable {
    var origin: Point<Number>
    var size: Size<Number>

    var minX: Number { origin.x }
    var minY: Number { origin.y }

    var maxX: Number { origin.x + size.width }
    var maxY: Number { origin.y + size.height }

    var width: Number { size.width }
    var height: Number { size.height }
}

extension AxisRect: Rect {
    init(x: Number, y: Number, width: Number, height: Number) {
        self.origin = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
}

extension AxisRect where Number: BinaryFloatingPoint {
    var midX: Number { origin.x + size.height / 2.0 }
    var midY: Number { origin.y + size.width / 2.0 }

    var horizontalRange: Number { size.width / 2.0 }
    var verticalRange: Number { size.height / 2.0 }
}
