import CSDL2

typealias MixChunkPtr = UnsafeMutablePointer<Mix_Chunk>

extension MixChunkPtr {
    private static func charToUChar(_ buffer: UnsafeMutablePointer<CChar>) -> UnsafeMutablePointer<UInt8> {
        UnsafeMutableRawPointer(OpaquePointer(buffer)).assumingMemoryBound(to: UInt8.self)
    }

    init(forWav resource: Assets.Music.Wav) throws {
        let file = try SDLRWopsPtr(file: resource.url.path)
        self = try sdlException { Mix_LoadWAV_RW(file, 1) }
    }

    func playOn(channel: CInt, loops: CInt = 0) {
        Mix_PlayChannelTimed(channel, self, loops, -1)
    }
}
