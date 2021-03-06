import NoobECS
import CSDL2

final class DefaultPool: SDLPool, Scene {

    func assumedWindow() {
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
            reserve: 100
        )

        try! Map(pool: self, loadFrom: .main).summonEntities()

        EntityFactory.player(
            schemeArrows: false,
            pool: self,
            asset: .white,
            spriteSheet: DynaSheet.self,
            position: Map.pointFrom(gridPosition: Point(x: 1, y: 1)),
            squareRadius: Size(width: 30, height: 30)
        )

        EntityFactory.player(
            schemeArrows: true,
            pool: self,
            asset: .green,
            spriteSheet: DynaSheet.self,
            position: Map.pointFrom(gridPosition: Point(x: 16, y: 1)),
            squareRadius: Size(width: 30, height: 30)
        )

        try! getRenderer()?.setDraw(blendMode: SDL_BLENDMODE_BLEND)
        try! resourceBuffer.music(for: .stage2).play()
    }

    func willResignWindow() {
        Mix_HaltMusic()
        _ = Mix_HaltChannel(-1)
    }

    override func update(with context: UpdateContext) throws {
        systems.forEach { system in 
            measure(String(describing: system.self)) {
                try! system.update(with: context)
            }
        }
    }

    override func willDestroy(entity: Entity) {
        if 
            let hasIntrospectionEntity = entity.access(component: IntrospectionComponent.self, accessBlock: \.labelWindowEntity)
        {
            entities.removeValue(forKey: hasIntrospectionEntity)
        }
    }
}

extension DefaultPool: CollisionSystemDelegate {
    func notifyCollisionOf(in system: AABBCollisionSystem, firstEntity: Entity, secondEntity: Entity, at time: UInt32) {
        switch (firstEntity.developerLabel, secondEntity.developerLabel) {
        case (EntityFactory.playerTag, EntityFactory.explosionTag):
            killPlayer(entity: firstEntity, at: time)
        case (EntityFactory.explosionTag, EntityFactory.playerTag):
            killPlayer(entity: secondEntity, at: time)
        case (EntityFactory.bonusTag, EntityFactory.playerTag):
            consume(bonus: firstEntity, by: secondEntity)
        case (EntityFactory.playerTag, EntityFactory.bonusTag):
            consume(bonus: secondEntity, by: firstEntity)
        default:
            print("Notify: collision of \(firstEntity) with \(secondEntity)")
        }
    }

    func reaffirmExceptions(in system: AABBCollisionSystem, for entity: Entity, exceptionComponent: inout Set<ObjectIdentifier>) {
        let collisions = Set(system.collisions(for: entity).map { ObjectIdentifier($0) })
        exceptionComponent.formIntersection(collisions)
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

        try! resourceBuffer.chunk(for: .dying).playOn(channel: -1)
    }

    private func consume(bonus entity: Entity, by player: Entity) {
        let bonusComponent = entity.access(component: BonusComponent.self) { $0 }

        player.access(component: PlayerComponent.self) { component in 
            component.bombLimit += bonusComponent!.bombLimit
            component.flameLength += bonusComponent!.flameLength
        }

        entities.removeValue(forKey: ObjectIdentifier(entity))
        try! resourceBuffer.chunk(for: .bonus).playOn(channel: -1)
    }
}

extension DefaultPool: TimerSystemDelegate {
    func firedTimer(for entity: Entity, context: TimedEventsComponent.ScheduledItem, at time: UInt32) {
        switch context.tag {
        case EntityFactory.bombExplosionTimerTag:
            explodeBomb(entity: entity, at: time)
        case "explosionExpired":
            removeExplosion(entity: entity)
        case "dying":
            playerDied(entity: entity)
        case EntityFactory.bonusBurningEffectTimerTag:
            removeBonusEffect(entity: entity)
        case EntityFactory.bonusBurningTimerTag:
            removeBonus(entity: entity)
        default: 
            print("Unhandled timer: \(entity), \(context)")
        }
    }

    private func playerDied(entity: Entity) {
        entities.removeValue(forKey: ObjectIdentifier(entity))
    }

    private func removeExplosion(entity: Entity) {
        entities.removeValue(forKey: ObjectIdentifier(entity))
    }

    private func removeBonus(entity: Entity) {
        entities.removeValue(forKey: ObjectIdentifier(entity))
    }

    private func removeBonusEffect(entity: Entity) {
        entities.removeValue(forKey: ObjectIdentifier(entity))
    }

    private func explodeBomb(entity: Entity, at time: UInt32) {
        let player = entity.access(component: BombComponent.self, accessBlock: \.summoningPlayer)
        player.flatMap { entities[$0] }?.access(component: PlayerComponent.self) { component in
            component.bombDeployed -= 1
        }
        let center = entity.access(component: BoxObjectComponent.self, accessBlock: \.centerRect.center)!
        let flameLength = entity.access(component: BombComponent.self, accessBlock: \.flameLength)!
        entities.removeValue(forKey: ObjectIdentifier(entity))

        EntityFactory.summonExplosion(pool: self, flameLength: flameLength, center: center, fireTime: time + EntityFactory.explosionDuration) { entity in
            switch entity.developerLabel {
            case EntityFactory.bombTag:
                moveExplosionTime(entity: entity, at: time)
            case EntityFactory.bonusTag:
                burnBonus(entity: entity, at: time)
            default: break
            }
        }

        try! resourceBuffer.chunk(for: .bomb).playOn(channel: -1)
    }

    private func moveExplosionTime(entity: Entity, at time: UInt32) {
        entity.access(component: TimedEventsComponent.self) { component in 
            let index = component.items.firstIndex { $0.tag == "bombExplosionTimer" }!

            component.items[index].fireTime = min(component.items[index].fireTime, time + EntityFactory.bombFireAfterHit)
        }
    }

    private func burnBonus(entity: Entity, at time: UInt32) {
        guard !entity.has(component: TimedEventsComponent.self) else {
            return
        }

        let center = entity.access(component: BoxObjectComponent.self) { component -> Point<Float> in
            component.collisionBitmask = 0
            component.notificationBitmask = 0
            component.categoryBitmask = 0
            return component.centerRect.center
        }!
        EntityFactory.burningBonusOverlay(pool: self, position: center, now: time)

        try! entity.assign(component: TimedEventsComponent.self, arguments: ())
        entity.access(component: TimedEventsComponent.self) { component in
            component.items.append(TimedEventsComponent.ScheduledItem(
                tag: EntityFactory.bonusBurningTimerTag,
                fireTime: time + EntityFactory.bonusBurningTime,
                associatedEntities: []
            ))
        }
    }
}