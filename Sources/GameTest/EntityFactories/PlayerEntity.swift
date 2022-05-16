import CSDL2

extension EntityFactory {
    @discardableResult
    static func player(
        asset: Assets.Image, 
        controllable: Bool,
        position: Point<Float>,
        squareRadius: Size<Float>,
        collisionBitmask: UInt32,
        initialVelocity: Vector<Float>
    ) -> Entity {
        let player = Entity()
        try! player.assign(
            component: MovableObjectComponent.self, 
            arguments: (
                positionCenter: position,
                squareRadius: squareRadius,
                categoryBitmask: 0b1,
                collisionBitmask: collisionBitmask,
                notificationBitmask: 0,
                velocity: initialVelocity, 
                maxVelocity: 1.0
            )
        )
        try! player.assign(
            component: SpriteComponent.self, 
            arguments: (asset: asset, size: squareRadius * 2, layer: 1)
        )
        if controllable {
            try! player.assign(
                component: ControllerComponent.self, 
                arguments: (
                    moveTopKey: SDL_SCANCODE_W, 
                    moveRightKey: SDL_SCANCODE_D, 
                    moveBottomKey: SDL_SCANCODE_S, 
                    moveLeftKey: SDL_SCANCODE_A
                )
            )
        }
        return player
    }
}
