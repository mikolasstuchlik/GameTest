extension EntityFactory {
    @discardableResult
    static func mapTile(pool: SDLPool, asset: Assets.Image, center: Point<Float>, squareRadius: Size<Float>, categoryBitmask: UInt32) -> Entity {
        let newTile = Entity(dataManager: pool)
        try! newTile.assign(
            component: SpriteComponent.self, 
            arguments: (
                unownedTexture: try! pool.textureBuffer.texture(for: asset),
                sourceRect: nil,
                size: squareRadius * 2,
                layer: 0
            )
        )
        try! newTile.assign(
            component: ImmovableObjectComponent.self, 
            arguments: (
                positionCenter: center,
                squareRadius: squareRadius,
                categoryBitmask: categoryBitmask
            )
        )
        return newTile
    }
}