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

    static func pointFrom(gridPosition point: Point<Int>) -> Point<Float> {
        Point(
            x: tileDimensions.width / 2 + tileDimensions.width * Float(point.x), 
            y: tileDimensions.height / 2 + tileDimensions.height * Float(point.y)
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
            .map { line in line.components(separatedBy: " ").filter { !$0.isEmpty } }

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

                let hasBox: Bool = content & 0b100000 > 0 // 32
                let hasBombBonus: Bool = content & 0b1000000 > 0 //64
                let hasFlameBonus: Bool = content & 0b10000000 > 0 //128

                switch content & 0b11111 {
                case 0:
                    EntityFactory.mapTile(pool: pool, asset: .grass, center: tile.center, squareRadius: tile.size * 0.5, collision: false)
                case 1:
                    EntityFactory.mapTile(pool: pool, asset: .pillar, center: tile.center, squareRadius: tile.size * 0.5, collision: true)
                case 2...17:
                    wallTile(at: tile.center, squareRadius: tile.size * 0.5, type: (content & 0b11111) - 3 )
                default: continue
                }

                if hasBox {
                    EntityFactory.box(
                        pool: pool, 
                        position: tile.center, 
                        squareRadius: tile.size * 0.5
                    )
                }

                if hasBombBonus {
                    EntityFactory.BonusKind.bonusBomb.addTo(pool: pool, position: tile.center)
                }

                if hasFlameBonus {
                    EntityFactory.BonusKind.bonusFlame.addTo(pool: pool, position: tile.center)
                }
            }
        }
    }

    func wallTile(at point: Point<Float>, squareRadius: Size<Float>, type: UInt) {
        EntityFactory.mapTile(
            pool: pool, 
            asset: .wall, 
            center: point, 
            squareRadius: squareRadius, 
            collision: true,
            sourceRect: WallSheet.rectFor(tileIndex: Int(type))
        )
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
