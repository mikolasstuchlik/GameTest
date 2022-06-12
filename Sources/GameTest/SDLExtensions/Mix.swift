import CSDL2

enum Mix {
    static func openAudio(frequency: CInt, format: CInt, channels: CInt, chunkSize: CInt) throws {
        try sdlException { Mix_OpenAudio(frequency, UInt16(format), channels, chunkSize) }
    }

    static func `init`(flags: MIX_InitFlags) throws {
        _ = try sdlExceptionOnZero { Mix_Init(CInt(flags.rawValue)) }
    }
}


