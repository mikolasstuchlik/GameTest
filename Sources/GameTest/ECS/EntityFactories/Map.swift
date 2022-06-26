import CSDL2
import NoobECS

final class Map {
    private weak var pool: SDLPool!

    static func gridPosition(point: Point<Float>) -> Point<Int> {
        Point(
            x: Int(point.x / tileDimensions.width), 
            y: Int(point.y / tileDimensions.height)
        )
    }

    static func alignToGrid(point: Point<Float>) -> Point<Float> {
        let gridPosition = gridPosition(point: point)

        return Point(
            x: tileDimensions.width / 2 + tileDimensions.width * Float(gridPosition.x), 
            y: tileDimensions.height / 2 + tileDimensions.height * Float(gridPosition.y)
        )
    }

    init(pool: SDLPool, loadFrom file: Assets.Map) throws {
        self.pool = pool

        let parsed = try String.init(contentsOf: file.url)
            .components(separatedBy: "\n")
            .map { $0.components(separatedBy: " ") }

        self.loadMap { tile in
            return UInt(parsed[tile.y][tile.x])!
        }
    }

    func summonEntities() {
        var tile = Rect<Float>(origin: .zero, size: Map.tileDimensions)

        for x in 0..<Map.mapDimensions.width {
            for y in 0..<Map.mapDimensions.height {
                let content = UInt(map[mapIndex(for: Point(x: x, y: y))])
                tile.origin.x = Map.tileDimensions.width * Float(x)
                tile.origin.y = Map.tileDimensions.height * Float(y)

                let hasBox: Bool = content & 0b1000 > 0

                let image: Assets.Image
                switch content & 0b111 {
                case 0:
                    image = .grass
                case 1:
                    image = .bricks
                default: continue
                }

                EntityFactory.mapTile(
                    pool: pool,
                    asset: image, 
                    center: tile.center, 
                    squareRadius: tile.size * 0.5, 
                    collision: image == .bricks
                )

                if hasBox {
                    EntityFactory.box(
                        pool: pool, 
                        asset: .crate, 
                        position: tile.center, 
                        squareRadius: tile.size * 0.5
                    )
                }
            }
        }
    }

    private func mapIndex(for point: Point<Int>) -> Int { point.x + point.y * Map.mapDimensions.width }

    private func loadMap(_ loader: (_ tile: Point<Int>) -> UInt) {
        for x in 0..<Map.mapDimensions.width {
            for y in 0..<Map.mapDimensions.height {
                let point = Point(x: x, y: y)
                map[mapIndex(for: point)] = loader(point)
            }
        } 
    }

    private var map: [UInt] = Array(repeating: UInt.max, count: mapDimensions.width * mapDimensions.height)

    static let mapDimensions = Size(width: 18, height: 12)
    static let tileDimensions = Size<Float>(width: 64, height: 64)
}
