import CSDL2

typealias MixMusicPtr = UnsafeMutablePointer<Mix_Music>

extension MixMusicPtr {
    init(forMus resource: Assets.Music.Ogg) throws {
        self = try sdlException { Mix_LoadMUS(resource.url.path) }
    }

    func play(loops: CInt = 0) throws {
        try sdlException { Mix_PlayMusic(self, loops) }
    }
}
