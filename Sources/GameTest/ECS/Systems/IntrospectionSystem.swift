import NoobECS
import NoobECSStores
import CSDL2
import Foundation

final class IntrospectionSystem: SDLSystem {
    override func update(with context: UpdateContext) throws {
        try handleInputEvents(in: context)
        try updateLiveDescriptions()
    }

    override func render(with context: RenderContext) throws {
        guard case .introspection = context.currentLayer else { return }
        let store = pool.storage(for: IntrospectionComponent.self)

        for index in 0..<store.buffer.count where store.buffer[index] != nil {
            let entity = store.buffer[index]!.unownedEntity
            let introspection = store.buffer[index]!.value

            try context.renderer.setDraw(color: introspection.color)

            for entity in introspection.frameCollidedWith {
                try entity.access(component: BoxObjectComponent.self) { component in 
                    try context.renderer.draw(line: Line(
                        from: component.positionCenter - Vector(x: component.squareRadius.width, y: component.squareRadius.height),
                        to: component.positionCenter + Vector(x: component.squareRadius.width, y: component.squareRadius.height)
                    ))
                    try context.renderer.draw(line: Line(
                        from: component.positionCenter - Vector(x: component.squareRadius.width, y: -component.squareRadius.height),
                        to: component.positionCenter + Vector(x: component.squareRadius.width, y: -component.squareRadius.height)
                    ))
                }
            }
            store.buffer[index]!.value.frameCollidedWith.removeAll()

            try entity.access(component: BoxObjectComponent.self) { component in
                try context.renderer.draw(
                    rect: SDL_Rect(Rect(
                        center: component.positionCenter, 
                        size: component.squareRadius * 2
                    ))
                )

                if component.velocity.magnitude > 0 {
                    try arrow(
                        from: component.positionCenter, 
                        length: component.velocity.magnitude
                    ).rotated(
                        around: component.positionCenter, 
                        angle: component.velocity.angleRad
                    ).draw(in: context.renderer)
                }
            }
        }
    }

    private func arrow(from: Point<Float>, length: Float) -> [Line<Float>] {
        let to = from + Vector(x: length, y: 0)
        return [
            Line(from: from, to: to + Vector(x: -8, y: 0)),
            Line(from: to, to: to + Vector(x: -8, y: -8) ),
            Line(from: to, to: to + Vector(x: -8, y: +8) ),
            Line(from: to + Vector(x: -8, y: +8), to: to + Vector(x: -8, y: -8) ),
        ]
    }

    private func handleInputEvents(in context: UpdateContext) throws {
        for inputEvent in context.events {
            guard case let .mouseKeyDown(mouseEvent) = inputEvent else {
                continue
            }
            
            let point = Point(x: Float(mouseEvent.x), y: Float(mouseEvent.y))

            let store = pool.storage(for: BoxObjectComponent.self)
            for index in 0..<store.buffer.count where store.buffer[index] != nil {
                guard 
                    Rect(
                        center: store.buffer[index]!.value.positionCenter, 
                        size: store.buffer[index]!.value.squareRadius * 2
                    ).contains(point) 
                else {
                    continue
                }

                switch CInt(mouseEvent.button) {
                case SDL_BUTTON_LEFT:
                    try toggleStatus(for: store.buffer[index]!.unownedEntity)
                case SDL_BUTTON_RIGHT:
                    selectNewColor(for: store.buffer[index]!.unownedEntity)
                default: continue
                }

                break 
            }
        }
    }

    private func updateLiveDescriptions() throws {
        let store = pool.storage(for: IntrospectionComponent.self)
        for index in 0..<store.buffer.count where store.buffer[index] != nil {
            let entity = store.buffer[index]!.unownedEntity
            var aggregator = ""
            aggregator += entity.access(component: AnimationComponent.self, accessBlock: { $0 } ).flatMap(String.init(describing:)).flatMap { $0 + "\n\n"} ?? ""
            aggregator += entity.access(component: BombComponent.self, accessBlock: { $0 } ).flatMap(String.init(describing:)).flatMap { $0 + "\n\n"} ?? ""
            aggregator += entity.access(component: BonusComponent.self, accessBlock: { $0 } ).flatMap(String.init(describing:)).flatMap { $0 + "\n\n"} ?? ""
            aggregator += entity.access(component: BoxObjectComponent.self, accessBlock: { $0 } ).flatMap(String.init(describing:)).flatMap { $0 + "\n\n"} ?? ""
            aggregator += entity.access(component: CollisionExceptionComponent.self, accessBlock: { $0 } ).flatMap(String.init(describing:)).flatMap { $0 + "\n\n"} ?? ""
            aggregator += entity.access(component: ControllerComponent.self, accessBlock: { $0 } ).flatMap(String.init(describing:)).flatMap { $0 + "\n\n"} ?? ""
            aggregator += entity.access(component: IntrospectionComponent.self, accessBlock: { $0 } ).flatMap(String.init(describing:)).flatMap { $0 + "\n\n"} ?? ""
            aggregator += entity.access(component: LabelComponent.self, accessBlock: { $0 } ).flatMap(String.init(describing:)).flatMap { $0 + "\n\n"} ?? ""
            aggregator += entity.access(component: PlayerComponent.self, accessBlock: { $0 } ).flatMap(String.init(describing:)).flatMap { $0 + "\n\n"} ?? ""
            aggregator += entity.access(component: SpriteComponent.self, accessBlock: { $0 } ).flatMap(String.init(describing:)).flatMap { $0 + "\n\n"} ?? ""
            aggregator += entity.access(component: TimedEventsComponent.self, accessBlock: { $0 } ).flatMap(String.init(describing:)).flatMap { $0 + "\n\n"} ?? ""

            let labelWindowEntity = store.buffer[index]!.value.labelWindowEntity
            labelWindowEntity.access(component: LabelComponent.self) { component in 
                let components = aggregator.components(separatedBy: "\n")
                let sizePerCharacter = Size<Float>(width: 10, height: 15)
                let maxWidth = Int(800)

                let numberOfWraps = components.map { 
                    (Int(sizePerCharacter.width * Float($0.count)) / maxWidth) + 1 
                }.reduce(0, +)

                let size = Size(
                    width: min(Float(maxWidth), sizePerCharacter.width * Float(components.map(\.count).max() ?? 0)), 
                    height: sizePerCharacter.height * Float(numberOfWraps)
                )
                
                component.wrapLength = UInt32(maxWidth)
                component.size = size
                component.position = Vector(x: Float(size.width) / 2, y: Float(size.height) / 2)
                component.color = store.buffer[index]!.value.color
                component.string = aggregator
            }
        }
    }

    private func toggleStatus(for entity: Entity) throws {
        guard !entity.has(component: IntrospectionComponent.self) else {
            entity.access(component: IntrospectionComponent.self) { component in 
                _ = pool.entities.removeValue(forKey: ObjectIdentifier(component.labelWindowEntity))
            }
            entity.destroy(component: IntrospectionComponent.self)
            return
        }

        let color = SDL_Color.colors.randomElement() ?? .white
        let labelWindowEntity = EntityFactory.labelBox(pool: pool as! SDLPool, color: color)
        try entity.assign(
            component: IntrospectionComponent.self, 
            arguments: (
                color: color,
                labelWindowEntity: labelWindowEntity
            )
        )
    }

    private func selectNewColor(for entity: Entity) {
        entity.access(component: IntrospectionComponent.self) { intro in
            let currentIndex = SDL_Color.colors.firstIndex(of: intro.color) ?? (0..<SDL_Color.colors.count).randomElement() ?? 0

            let nextIndex = currentIndex + 1 < SDL_Color.colors.count
                ? currentIndex + 1
                : 0
            
            intro.color = SDL_Color.colors[nextIndex]
        }
    }
}