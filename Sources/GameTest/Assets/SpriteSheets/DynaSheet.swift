import NoobECS

enum DynaSheet: SpriteSheet {
    static let defaultTile: Int = 0
    static let mapSize: Size<Int> = Size(width: 5, height: 4)
    static let tileSize: Size<Int> = Size(width: 23, height: 23)
    static let animations: [String : Animation] = [
        "idleDown"  : Animation(fps: 1, tiles: [0]),
        "goDown"    : Animation(fps: 8, tiles: [1, 0, 2, ]),
        "idleRight" : Animation(fps: 1, tiles: [3]),
        "goRight"   : Animation(fps: 8, tiles: [4, 3, 5, 3]),
        "idleLeft"  : Animation(fps: 1, tiles: [6]),
        "goLeft"    : Animation(fps: 8, tiles: [7, 6, 8, 6]),
        "idleUp"    : Animation(fps: 1, tiles: [9]),
        "goUp"      : Animation(fps: 8, tiles: [10, 9, 11, 9]),
        "death"     : Animation(fps: 12, tiles: [13, 14, 15, 16, 17, 18, 19, 20])
    ]

    static func nextAnimation(for entity: Entity, current animation: String?) -> String? {
        guard
            let movementVector = entity.access(component: PhysicalObjectComponent.self, accessBlock: { component in
                return Vector<Float>(from: component.startingPosition, to: component.positionCenter)
            })
        else {
            return animation
        }

        let degrees = movementVector.degreees
        let magnitude = movementVector.magnitude

        guard magnitude != 0 else {
            switch animation {
            case "idleDown", "goDown":
                return "idleDown"
            case "idleRight", "goRight":
                return "idleRight"
            case "goLeft", "idleLeft":
                return "idleLeft"
            case "goUp", "idleUp":
                return "idleUp"
            default:
            return nil
            }
        }

        switch degrees {
        case 316...361, 0..<46:
            return "goRight"
        case 46.0..<136.0:
            return "goDown"
        case 136.0..<226.0:
            return "goLeft"
        case 226.0..<316.0:
            return "goUp"
        default:
            return nil
        }
    }
}