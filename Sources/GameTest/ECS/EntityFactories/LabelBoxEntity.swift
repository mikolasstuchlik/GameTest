import CSDL2
import NoobECS

extension EntityFactory {
    @discardableResult
    static func labelBox(
        pool: SDLPool,
        color: SDL_Color
    ) -> Entity {
        let player = Entity(dataManager: pool)
        try! player.assign(
            component: BoxObjectComponent.self, 
            options: .immaterial,
            arguments: (
                positionCenter: .zero,
                squareRadius: .zero,
                categoryBitmask: 0,
                collisionBitmask: 0,
                notificationBitmask: 0,
                velocity: .zero, 
                maxVelocity: 0
            )
        )
        var black33 = SDL_Color.black
        black33.a = 255 / 3

        try! player.assign(
            component: LabelComponent.self, 
            options: .introspection,
            arguments: (
                unownedFont: try! pool.resourceBuffer.font(for: .vcrOsdMono, size: 15), 
                string: "", 
                color: color,
                wrapLength: 0,
                size: Size(width: 0, height: 0), 
                position: .zero,
                background: black33
            )
        )
        return player
    }
}
