import NoobECS

enum BonusBurningSheet: SpriteSheet {
    static let defaultTile: Int = 0
    static let mapSize: Size<Int> = Size(width: 2, height: 4)
    static let tileSize: Size<Int> = Size(width: 27, height: 27)
    static let animations: [String : Animation] = [
        "burning"  : Animation(fps: 8, tiles: [0, 1, 2, 3, 4, 5, 6]),
    ]

    static func nextAnimation(for entity: Entity, current animation: String?) -> String? { "burning" }
}
