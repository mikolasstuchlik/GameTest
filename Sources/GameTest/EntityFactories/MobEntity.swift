import CSDL2

extension EntityFactory {
    @discardableResult
    static func mob(
        pool: Pool,
        asset: Assets.Image, 
        position: Point<Float>,
        squareRadius: Size<Float>,
        collisionBitmask: UInt32,
        initialVelocity: Vector<Float>
    ) -> Entity {
        let mob = Entity(pool: pool)
        try! mob.assign(
            component: MovableObjectComponent.self, 
            arguments: (
                positionCenter: position,
                squareRadius: squareRadius,
                categoryBitmask: 0b1,
                collisionBitmask: collisionBitmask,
                notificationBitmask: 0,
                velocity: initialVelocity, 
                maxVelocity: 100.0
            )
        )
        try! mob.assign(
            component: SpriteComponent.self, 
            arguments: (
                unownedTexture: try! pool.textureBuffer.texture(for: asset), 
                sourceRect: nil,
                size: squareRadius * 2, 
                layer: 1
            )
        )
        return mob
    }
}
