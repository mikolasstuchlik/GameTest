extension EntityFactory {
    @discardableResult
    static func mapTile(asset: Assets.Image, center: Point<Float>, squareRadius: Size<Float>, categoryBitmask: UInt32) -> Entity {
        let newTile = Entity()
        try! newTile.assign(
            component: SpriteComponent.self, 
            arguments: (asset: asset, size: squareRadius * 2, layer: 0)
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