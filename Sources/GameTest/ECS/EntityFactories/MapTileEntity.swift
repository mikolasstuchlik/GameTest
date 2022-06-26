import NoobECS

extension EntityFactory {
    static let tileCategory: UInt32 = 0b1
    static let mapWallTag = "wall"
    static let groundTag = "ground"

    @discardableResult
    static func mapTile(pool: SDLPool, asset: Assets.Image, center: Point<Float>, squareRadius: Size<Float>, collision: Bool) -> Entity {
        let newTile = Entity(dataManager: pool)
        try! newTile.assign(
            component: SpriteComponent.self, 
            options: .background,
            arguments: (
                unownedTexture: try! pool.resourceBuffer.texture(for: asset),
                sourceRect: nil,
                size: squareRadius * 2
            )
        )
        try! newTile.assign(
            component: BoxObjectComponent.self,
            options: collision ? .immovable : .immaterial,
            arguments: (
                positionCenter: center,
                squareRadius: squareRadius,
                categoryBitmask: collision ? tileCategory : 0,
                collisionBitmask: 0,
                notificationBitmask: 0,
                velocity: .zero,
                maxVelocity: 0
            )
        )
        newTile.developerLabel = collision
            ? EntityFactory.mapWallTag
            : EntityFactory.groundTag

        return newTile
    }
}