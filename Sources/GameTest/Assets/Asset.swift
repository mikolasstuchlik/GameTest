import Foundation
import CSDL2
import NoobECS

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
        case fish, evilFish, water, sand, plains, crate, grass, bricks, wall, pillar

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
        case blue, green, red, white, explosion, bomb, bombBonus, flameBonus, bonusBurning

        var url: URL {
            Bundle.module.url(forResource: self.rawValue, withExtension: "png")!
        }
    }

    enum Font: String {
        case disposableDroidBold = "DisposableDroidBB_bld"
        case disposableDroidBoldItalic = "DisposableDroidBB_bldital"
        case disposableDroidItalic = "DisposableDroidBB_ital"
        case disposableDroid = "DisposableDroidBB"
        case vcrOsdMono = "VCR_OSD_MONO"

        var url: URL {
            Bundle.module.url(forResource: self.rawValue, withExtension: "ttf")!
        }
    }

    enum Music {
        enum Ogg: String {
            case stage2

            var url: URL {
                Bundle.module.url(forResource: self.rawValue, withExtension: "ogg")!
            }
        }

        enum Wav: String {
            case bomb, bonus, dying, gong

            var url: URL {
                Bundle.module.url(forResource: self.rawValue, withExtension: "wav")!
            }
        }
    }
}
