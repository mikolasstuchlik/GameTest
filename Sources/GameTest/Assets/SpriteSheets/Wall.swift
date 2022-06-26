import NoobECS

enum WallSheet: SpriteSheet {
    static let defaultTile: Int = 0
    static let mapSize: Size<Int> = Size(width: 15, height: 1)
    static let tileSize: Size<Int> = Size(width: 16, height: 16)
    static let animations: [String : Animation] = [:]

    static func nextAnimation(for entity: Entity, current animation: String?) -> String? { nil }
}
