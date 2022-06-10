import CSDL2
import NoobECS


extension EntityFactory {
    static let playerCategory: UInt32 = 0b10

    @discardableResult
    static func player(
        schemeArrows: Bool,
        pool: SDLPool,
        asset: Assets.Sheet,
        spriteSheet: SpriteSheet.Type,
        position: Point<Float>,
        squareRadius: Size<Float>
    ) -> Entity {
        let player = Entity(dataManager: pool)
        player.developerLabel = "player"
        try! player.assign(
            component: BoxObjectComponent.self, 
            options: .movable,
            arguments: (
                positionCenter: position,
                squareRadius: squareRadius,
                categoryBitmask: playerCategory,
                collisionBitmask: boxCategory | tileCategory | bombCategory,
                notificationBitmask: playerCategory | explosionCategory,
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
                moveLeftKey:    !schemeArrows ? SDL_SCANCODE_A : SDL_SCANCODE_LEFT,
                summonBomb:     !schemeArrows ? SDL_SCANCODE_Q : SDL_SCANCODE_M
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
        try! player.assign(
            component: LabelComponent.self, 
            options: .avatar,
            arguments: (
                unownedFont: try! pool.textureBuffer.font(for: .disposableDroid, size: 20), 
                string: "Player", 
                color: .white,
                wrapLength: 0,
                size: Size(width: 64, height: 20), 
                position: Vector(x: 0, y: -40)
            )
        )
        return player
    }
}
