import NoobECS

enum BombBonusSheet: SpriteSheet {
    static let defaultTile: Int = 0
    static let mapSize: Size<Int> = Size(width: 1, height: 2)
    static let tileSize: Size<Int> = Size(width: 16, height: 16)
    static let animations: [String : Animation] = [
        "bonus"  : Animation(fps: 4, tiles: [0, 1]),
    ]

    static func nextAnimation(for entity: Entity, current animation: String?) -> String? { "bonus" }
}
