import CSDL2

extension EntityFactory {
    @discardableResult
    static func player(
        schemeArrows: Bool,
        pool: Pool,
        asset: Assets.Sheet,
        spriteSheet: SpriteSheet.Type,
        position: Point<Float>,
        squareRadius: Size<Float>,
        collisionBitmask: UInt32
    ) -> Entity {
        let player = Entity(pool: pool)
        try! player.assign(
            component: MovableObjectComponent.self, 
            arguments: (
                positionCenter: position,
                squareRadius: squareRadius,
                categoryBitmask: 0b1,
                collisionBitmask: collisionBitmask,
                notificationBitmask: 0,
                velocity: .zero, 
                maxVelocity: 200.0
            )
        )
        try! player.assign(
            component: SpriteComponent.self, 
            arguments: (
                unownedTexture: try! pool.textureBuffer.texture(for: asset), 
                sourceRect: nil,
                size: squareRadius * 2, 
                layer: 1
            )
        )
        try! player.assign(
            component: AnimationComponent.self,
            arguments: (
                spriteSheet: spriteSheet,
                startTime: 0,
                currentAnimation: nil
            )
        )
        try! player.assign(
                component: ControllerComponent.self, 
                arguments: (
                    moveTopKey:     !schemeArrows ? SDL_SCANCODE_W : SDL_SCANCODE_UP, 
                    moveRightKey:   !schemeArrows ? SDL_SCANCODE_D : SDL_SCANCODE_RIGHT, 
                    moveBottomKey:  !schemeArrows ? SDL_SCANCODE_S : SDL_SCANCODE_DOWN, 
                    moveLeftKey:    !schemeArrows ? SDL_SCANCODE_A : SDL_SCANCODE_LEFT
                )
            )
        return player
    }
}
