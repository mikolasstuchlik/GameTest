final class DefaultPool: SDLPool {

    func setup() {
        let collisionSystem = AABBCollisionSystem(pool: self)
        collisionSystem.delegate = self

        systems = [
            UserInputSystem(pool: self),
            MovementSystem(pool: self),
            AnimationSystem(pool: self),
            collisionSystem,
            RenderSystem(pool: self),
        ]

        self.storage(for: SpriteComponent.self).initialize(
            categories: [
                .avatar: 10, 
                .background: Map.mapDimensions.height * Map.mapDimensions.width
            ], 
            reserve: 0
        )

        try! Map(pool: self, loadFrom: .main).summonEntities()
        EntityFactory.player(
            schemeArrows: false,
            pool: self,
            asset: .white,
            spriteSheet: DynaSheet.self,
            position: Point(x: 32, y: 256),
            squareRadius: Size(width: 30, height: 30),
            collisionBitmask: 0b1
        ).developerLabel = "player"

        EntityFactory.player(
            schemeArrows: true,
            pool: self,
            asset: .green,
            spriteSheet: DynaSheet.self,
            position: Point(x: 32, y: 180),
            squareRadius: Size(width: 30, height: 30),
            collisionBitmask: 0b1
        ).developerLabel = "player2"
    }

    override func update(with context: UpdateContext) throws {
        systems.forEach { system in 
            measure(String(describing: system.self)) {
                try! system.update(with: context)
            }
        }
    }
}

extension DefaultPool: CollisionSystemDelegate {
    func notifyCollisionOf(firstEntity: Entity, secondEntity: Entity) {
        
    }
}
