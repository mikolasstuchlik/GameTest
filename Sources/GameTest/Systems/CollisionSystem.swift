protocol CollisionSystemDelegate: AnyObject {
    func entity(_ firstEntity: Entity, collidedWith secondEntity: Entity)
}

final class CollisionSystem: System {
    weak var delegate: CollisionSystemDelegate?

    func update(with context: UpdateContext) throws {
        
    }

    func render(with context: RenderContext) throws {
        
    }
}