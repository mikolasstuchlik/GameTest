import NoobECS

enum ExplosionSheet: SpriteSheet {
    enum Cases: String {
        case center, horiz, vert, rightTip, downTip, leftTip, upTip
    }

    static let defaultTile: Int = 0
    static let mapSize: Size<Int> = Size(width: 6, height: 5)
    static let tileSize: Size<Int> = Size(width: 16, height: 16)
    static let animations: [String : Animation] = [
        Cases.center.rawValue    : Animation(fps: 8, tiles: [3, 2, 1, 0, 1, 2, 3, 4]),
        Cases.horiz.rawValue     : Animation(fps: 8, tiles: [8, 7, 6, 5, 5, 6, 7, 8]),
        Cases.vert.rawValue      : Animation(fps: 8, tiles: [12, 11, 10, 9, 9, 10, 11, 12]),
        Cases.rightTip.rawValue  : Animation(fps: 8, tiles: [24, 23, 22, 21, 21, 22, 23, 24]),
        Cases.downTip.rawValue   : Animation(fps: 8, tiles: [20, 19, 18, 17, 17, 18, 19, 20]),
        Cases.leftTip.rawValue   : Animation(fps: 8, tiles: [16, 15, 14, 13, 13, 14, 15, 16]),
        Cases.upTip.rawValue     : Animation(fps: 8, tiles: [28, 27, 26, 25, 25, 26, 27, 28])
    ]

    static func nextAnimation(for entity: Entity, current animation: String?) -> String? { animation }
}
