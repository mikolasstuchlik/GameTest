import CSDL2

final class Map {
    private unowned(unsafe) let pool: Pool

    init(pool: Pool, loadFrom file: Assets.Map) throws {
        self.pool = pool

        let parsed = try String.init(contentsOf: file.url)
            .components(separatedBy: "\n")
            .map { $0.components(separatedBy: " ") }

        self.loadMap { tile in
            return Int(parsed[tile.y][tile.x])!
        }
    }

    func summonEntities() {
        var tile = Rect<Float>(origin: .zero, size: Map.tileDimensions)

        for x in 0..<Map.mapDimensions.width {
            for y in 0..<Map.mapDimensions.height {
                let content = map[mapIndex(for: Point(x: x, y: y))]
                tile.origin.x = Map.tileDimensions.width * Float(x)
                tile.origin.y = Map.tileDimensions.height * Float(y)
                
                let image: Assets.Image
                switch content {
                case 0:
                    image = .water
                case 1:
                    image = .plains
                case 2:
                    image = .sand
                default: continue
                }

                EntityFactory.mapTile(
                    pool: pool,
                    asset: image, 
                    center: tile.center, 
                    squareRadius: tile.size * 0.5, 
                    categoryBitmask: 0
                ).developerLabel = "mapTile"
            }
        }
    }

    private func mapIndex(for point: Point<Int>) -> Int { point.x + point.y * Map.mapDimensions.width }

    private func loadMap(_ loader: (_ tile: Point<Int>) -> Int) {
        for x in 0..<Map.mapDimensions.width {
            for y in 0..<Map.mapDimensions.height {
                let point = Point(x: x, y: y)
                map[mapIndex(for: point)] = loader(point)
            }
        } 
    }

    private var map: [Int] = Array(repeating: -1, count: mapDimensions.width * mapDimensions.height)

    static let mapDimensions = Size(width: 25, height: 20)
    static let tileDimensions = Size<Float>(width: 32, height: 32)
}
