import NoobECS

extension EntityFactory {
    @discardableResult
    static func mapTile(pool: SDLPool, asset: Assets.Image, center: Point<Float>, squareRadius: Size<Float>, categoryBitmask: UInt32) -> Entity {
        let newTile = Entity(dataManager: pool)
        try! newTile.assign(
            component: SpriteComponent.self, 
            options: .background,
            arguments: (
                unownedTexture: try! pool.textureBuffer.texture(for: asset),
                sourceRect: nil,
                size: squareRadius * 2
            )
        )
        try! newTile.assign(
            component: PhysicalObjectComponent.self,
            options: categoryBitmask > 0 ? .immovable : .immaterial,
            arguments: (
                positionCenter: center,
                squareRadius: squareRadius,
                categoryBitmask: categoryBitmask,
                collisionBitmask: 0,
                notificationBitmask: 0,
                velocity: .zero,
                maxVelocity: 0
            )
        )
        return newTile
    }
}