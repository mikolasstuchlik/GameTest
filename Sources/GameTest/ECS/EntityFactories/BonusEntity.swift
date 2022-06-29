import CSDL2
import NoobECS

extension EntityFactory {
    static let bonusCategory: UInt32 = 0b100000
    static let bonusTag = "bonus"
    static let burningBonusTag = "burningBonus"
    static let bonusSquareRadius = Size<Float>(width: 32, height: 32)
    static let bonusCollisionRadius = Size<Float>(width: 28, height: 28)
    static let bonusBurningTime: UInt32 = 625
    static let bonusBurningEffectTime: UInt32 = 875
    static let bonusBurningTimerTag = "bonusBurning"
    static let bonusBurningEffectTimerTag = "bonusBurningEffectExpired"

    enum BonusKind {
        case bonusBomb, bonusFlame

        private var sprite: Assets.Sheet {
            switch self {
            case .bonusBomb:
                return .bombBonus
            case .bonusFlame:
                return .flameBonus
            }
        }

        private var sheet: SpriteSheet.Type {
            switch self {
            case .bonusBomb:
                return BombBonusSheet.self
            case .bonusFlame:
                return FlameBonusSheet.self
            }
        }

        private var bonusProperties: (Int, Int) {
            switch self {
            case .bonusBomb:
                return (1, 0)
            case .bonusFlame:
                return (0, 1)
            }
        }

        @discardableResult
        func addTo(
            pool: SDLPool,
            position: Point<Float>
        ) -> Entity {
            let bonus = Entity(dataManager: pool)
            
            try! bonus.assign(
                component: BoxObjectComponent.self, 
                options: .immovable,
                arguments: (
                    centerRect: CenterRect(center: position, range: EntityFactory.bonusCollisionRadius),
                    categoryBitmask: EntityFactory.bonusCategory,
                    collisionBitmask: 0,
                    notificationBitmask: EntityFactory.playerCategory,
                    velocity: .zero, 
                    maxVelocity: 0
                )
            )
            try! bonus.assign(
                component: SpriteComponent.self, 
                options: .bonus,
                arguments: (
                    unownedTexture: try! pool.resourceBuffer.texture(for: self.sprite), 
                    sourceRect: nil,
                    size: EntityFactory.bonusSquareRadius * 2
                )
            )
            try! bonus.assign(
                component: AnimationComponent.self,
                arguments: (
                    spriteSheet: self.sheet,
                    startTime: 0,
                    currentAnimation: nil
                )
            )
            try! bonus.assign(
                component: BonusComponent.self, 
                arguments: self.bonusProperties
            )
            
            bonus.developerLabel = EntityFactory.bonusTag
            return bonus
        }
    }

    @discardableResult
    static func burningBonusOverlay(
        pool: SDLPool,
        position: Point<Float>,
        now time: UInt32
    ) -> Entity {
        let bonus = Entity(dataManager: pool)
        
        try! bonus.assign(
            component: BoxObjectComponent.self, 
            options: .immaterial,
            arguments: (
                centerRect: CenterRect(center: position, range: EntityFactory.bonusCollisionRadius),
                categoryBitmask: 0,
                collisionBitmask: 0,
                notificationBitmask: 0,
                velocity: .zero, 
                maxVelocity: 0
            )
        )
        try! bonus.assign(
            component: SpriteComponent.self, 
            options: .bonusBurn,
            arguments: (
                unownedTexture: try! pool.resourceBuffer.texture(for: .bonusBurning), 
                sourceRect: nil,
                size: EntityFactory.bonusSquareRadius * 2
            )
        )
        try! bonus.assign(
            component: AnimationComponent.self,
            arguments: (
                spriteSheet: BonusBurningSheet.self,
                startTime: 0,
                currentAnimation: nil
            )
        )
        try! bonus.assign(component: TimedEventsComponent.self, arguments: ())
        bonus.access(component: TimedEventsComponent.self) { component in
            component.items.append(TimedEventsComponent.ScheduledItem(
                tag: bonusBurningEffectTimerTag,
                fireTime: time + bonusBurningEffectTime,
                associatedEntities: []
            ))
        }
        
        bonus.developerLabel = EntityFactory.burningBonusTag
        return bonus
    }
}
