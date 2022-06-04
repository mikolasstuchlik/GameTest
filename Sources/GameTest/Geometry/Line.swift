struct Line<Number: Numeric> {
    var origin: Point<Number>
    var vector: Vector<Number>
}

extension Line where Number: FloatingPoint {
    init(from: Point<Number>, to: Point<Number>) {
        self.origin = from
        self.vector = from → to
    }
}

extension Line where Number: BinaryFloatingPoint {
    init<Other: BinaryFloatingPoint>(_ other: Line<Other>) {
        self.origin = Point<Number>(other.origin)
        self.vector = Vector<Number>(other.vector)
    }
}

extension Line where Number: BinaryFloatingPoint {
    func collinear(with line: Line) -> Bool {
        self.vector ⨯ line.vector == 0
        && self.origin → line.origin ⨯ self.vector == 0
    }

    func parallel(with line: Line) -> Bool {
        self.vector ⨯ line.vector == 0
        && self.origin → line.origin ⨯ self.vector != 0
    }

    func intersection(with otherLine: Line) -> Number {
        self.origin → otherLine.origin
        ⨯ otherLine.vector 
        / (self.vector ⨯ otherLine.vector) 
    }
}

extension Rect where Number: BinaryFloatingPoint {

    /// It is guaranteed, that lines are always in followin order: top, right, bottom, left
    // TODO: We also might introduce some sort of "CollectionOfFour"
    var lines: [Line<Number>] {
        let points = [
            origin,
            Point(x: origin.x + size.width, y: origin.y),
            Point(x: origin.x + size.width, y: origin.y + size.height),
            Point(x: origin.x, y: origin.y + size.height),
        ]

        return [
            Line(from: points[0], to: points[1]),
            Line(from: points[1], to: points[2]),
            Line(from: points[2], to: points[3]),
            Line(from: points[3], to: points[0]),
        ]
    }
}
