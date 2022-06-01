import CSDL2
import NoobECS


extension EntityFactory {
    @discardableResult
    static func player(
        schemeArrows: Bool,
        pool: SDLPool,
        asset: Assets.Sheet,
        spriteSheet: SpriteSheet.Type,
        position: Point<Float>,
        squareRadius: Size<Float>,
        collisionBitmask: UInt32
    ) -> Entity {
        let player = Entity(dataManager: pool)
        try! player.assign(
            component: BoxObjectComponent.self, 
            options: .movable,
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
            options: .avatar,
            arguments: (
                unownedTexture: try! pool.textureBuffer.texture(for: asset), 
                sourceRect: nil,
                size: squareRadius * 2
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
        try! player.assign(
            component: InventoryComponent.self, 
            arguments: (
                bombLimit: 1,
                bombDeployed: 0,
                flameLength: 2
            )
        )
        return player
    }
}
