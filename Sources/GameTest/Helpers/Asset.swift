import Foundation

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
}