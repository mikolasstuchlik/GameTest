import NoobECS
import CSDL2

final class DefaultPool: SDLPool {

    func setup() {
        let collisionSystem = AABBCollisionSystem(pool: self)
        collisionSystem.delegate = self

        let timerSystem = TimerSystem(pool: self)
        timerSystem.delegate = self

        systems = [
            timerSystem,
            UserInputSystem(pool: self),
            MovementSystem(pool: self),
            AnimationSystem(pool: self),
            collisionSystem,
            SpriteRenderSystem(pool: self),
            LabelRenderSystem(pool: self),
            IntrospectionSystem(pool: self),
        ]

        self.storage(for: SpriteComponent.self).initialize(
            categories: [
                .avatar: 10, 
                .item: 20,
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
            position: Point(x: 64 + 32, y: 64 + 32),
            squareRadius: Size(width: 30, height: 30)
        )

        EntityFactory.player(
            schemeArrows: true,
            pool: self,
            asset: .green,
            spriteSheet: DynaSheet.self,
            position: Point(x: 64 + 32, y: 64 + 64 + 64 + 32),
            squareRadius: Size(width: 30, height: 30)
        )

        try! getRenderer()?.setDraw(blendMode: SDL_BLENDMODE_BLEND)
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
    func notifyCollisionOf(firstEntity: Entity, secondEntity: Entity, at time: UInt32) {
        switch (firstEntity.developerLabel, secondEntity.developerLabel) {
        case ("player", "explosion"):
            killPlayer(entity: firstEntity, at: time)
        case ("explosion", "player"):
            killPlayer(entity: secondEntity, at: time)
        case ("bomb", "explosion"):
            moveExplosionTime(entity: firstEntity, at: time)
        case ("explosion", "bomb"):
            moveExplosionTime(entity: secondEntity, at: time)
        default:
            print("Notify: collision of \(firstEntity) with \(secondEntity)")
        }
    }

    private func killPlayer(entity: Entity, at time: UInt32) {
        /// We should probably introduce some component to describe player entity, but this is fine for now
        let timers = entity.access(component: TimedEventsComponent.self, accessBlock: \.items)

        guard timers?.contains(where: { $0.tag == "dying" }) != true else {
            return
        }

        try! entity.assign(component: TimedEventsComponent.self, arguments: ())
        entity.access(component: TimedEventsComponent.self) { component in 
            component.items.append(TimedEventsComponent.ScheduledItem(
                tag: "dying", 
                fireTime: time + 1000, 
                associatedEntities: []
            ))
        }

        entity.destroy(component: ControllerComponent.self)
        entity.access(component: BoxObjectComponent.self) { component in
            component.velocity = .zero
            component.maxVelocity = 0
        }
        
        entity.access(component: AnimationComponent.self) { component in
            component.currentAnimation = "death"
        }

        try! MixChunkPtr(forWav: .dying).playOn(channel: -1)
    }

    private func moveExplosionTime(entity: Entity, at time: UInt32) {
        entity.access(component: TimedEventsComponent.self) { component in 
            let index = component.items.firstIndex { $0.tag == "bombExplosionTimer" }!

            component.items[index].fireTime = min(component.items[index].fireTime, time + 100)
        }
    }
}

extension DefaultPool: TimerSystemDelegate {
    func firedTimer(for entity: Entity, context: TimedEventsComponent.ScheduledItem, at time: UInt32) {
        switch context.tag {
        case "bombExplosionTimer":
            explodeBomb(entity: entity, at: time)
        case "explosionExpired":
            removeExplosion(entity: entity)
        case "dying":
            playerDied(entity: entity)
        default: 
            print("Unhandled timer: \(entity), \(context)")
        }
    }

    private func playerDied(entity: Entity) {
        entities.remove(entity)
    }

    private func removeExplosion(entity: Entity) {
        entities.remove(entity)
    }

    private func explodeBomb(entity: Entity, at time: UInt32) {
        let center = entity.access(component: BoxObjectComponent.self, accessBlock: \.positionCenter)!
        entities.remove(entity)
        EntityFactory.summonExplosion(pool: self, center: center, fireTime: time + 500)
        try! MixChunkPtr(forWav: .bomb).playOn(channel: -1)
    }
}