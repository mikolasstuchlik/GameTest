final class DefaultPool: BasePool {
    override init(application: Application) {
        super.init(application: application)
    }

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

        // EntityFactory.mob(
        //     pool: self,
        //     asset: .evilFish, 
        //     position: .zero, 
        //     squareRadius: Size(width: 32, height: 32), 
        //     collisionBitmask: 0, 
        //     initialVelocity: Vector(x: 75, y: 75)
        // ).developerLabel = "enemy"

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
