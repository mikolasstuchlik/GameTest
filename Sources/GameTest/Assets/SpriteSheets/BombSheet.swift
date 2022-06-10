import NoobECS

enum BombSheet: SpriteSheet {
    static let defaultTile: Int = 0
    static let mapSize: Size<Int> = Size(width: 1, height: 3)
    static let tileSize: Size<Int> = Size(width: 16, height: 16)
    static let animations: [String : Animation] = [
        "bomb"  : Animation(fps: 2, tiles: [0, 1, 0, 2]),
    ]

    static func nextAnimation(for entity: Entity, current animation: String?) -> String? { "bomb" }
}
