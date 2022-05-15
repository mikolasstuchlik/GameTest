import CLibs

struct ControllerComponent: Component {
    static var storage: [Self] = []
    static var freedIndicies: [Int] = []
    static var componentIdentifier = makeIdentifier()

    // this could be unowned(unsafe) reference
    var entity: Entity.Identifier

    var moveTopKey: SDL_Scancode
    var moveRightKey: SDL_Scancode
    var moveBottomKey: SDL_Scancode
    var moveLeftKey: SDL_Scancode

    var isTopPressed: Bool = false
    var isRightPressed: Bool = false
    var isBottomPressed: Bool = false
    var isLeftPressed: Bool = false

    mutating func respondsTo(key: SDL_Scancode, pressed: Bool) -> Bool {
        if moveTopKey == key, isTopPressed != pressed {
            isTopPressed.toggle()
            return true
        }

        if moveRightKey == key, isRightPressed != pressed {
            isRightPressed.toggle()
            return true
        }

        if moveBottomKey == key, isBottomPressed != pressed {
            isBottomPressed.toggle()
            return true
        }

        if moveLeftKey == key, isLeftPressed != pressed {
            isLeftPressed.toggle()
            return true
        }

        return false
    }

    init(
        entity: Entity.Identifier, 
        arguments: (
            moveTopKey: SDL_Scancode,
            moveRightKey: SDL_Scancode,
            moveBottomKey: SDL_Scancode,
            moveLeftKey: SDL_Scancode
        )
    ) {
        self.entity = entity
        self.moveTopKey = arguments.moveTopKey
        self.moveRightKey = arguments.moveRightKey
        self.moveBottomKey = arguments.moveBottomKey
        self.moveLeftKey = arguments.moveLeftKey
    }

    func destroy() { }
}