struct CenterRect<Number: Numeric>: Equatable {
    var center: Point<Number>
    var range: Size<Number>

    var minX: Number { center.x - range.width }
    var minY: Number { center.y - range.height }

    var midX: Number { center.x }
    var midY: Number { center.y }

    var maxX: Number { center.x + range.width }
    var maxY: Number { center.y + range.height }

    var width: Number { range.width * 2 }
    var height: Number { range.height * 2 }

    var horizontalRange: Number { range.width }
    var verticalRange: Number { range.height }
}

extension CenterRect: Rect where Number: BinaryFloatingPoint {
    init(x: Number, y: Number, width: Number, height: Number) {
        let range = Size<Number>(width: width / 2, height: height / 2)
        self.center = Point(x: x + range.width, y: y + range.height)
        self.range = range
    }
}
