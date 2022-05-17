import Foundation
import CSDL2

struct Animation {
    let fps: Int
    let tiles: [Int]
}

protocol SpriteSheet {
    static var defaultTile: Int { get }
    static var mapSize: Size<Int> { get }
    static var tileSize: Size<Int> { get }
    static var animations: [String: Animation] { get }

    static func rectFor(tileIndex: Int) -> SDL_Rect
    static func nextAnimation(for entity: Entity, current animation: String?) -> String?
}

extension SpriteSheet {
    static func rectFor(tileIndex: Int) -> SDL_Rect {
        let row = tileIndex % mapSize.height
        let column = tileIndex / mapSize.height

        return SDL_Rect(
            x: CInt(column * tileSize.width), 
            y: CInt(row * tileSize.height), 
            w: CInt(tileSize.width), 
            h: CInt(tileSize.height)
        )
    }
}

enum Assets { 
    enum Image: String {
        case fish, evilFish, water, sand, plains

        var url: URL {
            Bundle.module.url(forResource: self.rawValue, withExtension: "png")!
        }
    }

    enum Map: String {
        case main

        var url: URL {
            Bundle.module.url(forResource: self.rawValue, withExtension: "map")!
        }
    }

    enum Sheet: String {
        case dyna

        var url: URL {
            Bundle.module.url(forResource: self.rawValue, withExtension: "png")!
        }
    }
}
