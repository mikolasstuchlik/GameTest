import CSDL2
import NoobECS
import NoobECSStores


struct ControllerComponent: Component {
    typealias Store = VectorStorage<Self>

    var moveTopKey: SDL_Scancode
    var moveRightKey: SDL_Scancode
    var moveBottomKey: SDL_Scancode
    var moveLeftKey: SDL_Scancode
    var summonBomb: SDL_Scancode

    var isTopPressed: Bool = false
    var isRightPressed: Bool = false
    var isBottomPressed: Bool = false
    var isLeftPressed: Bool = false
    var shouldSummonBomb: Bool = false

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

        if summonBomb == key, shouldSummonBomb != pressed {
            shouldSummonBomb = true
            return true
        }

        return false
    }

    init(
        arguments: (
            moveTopKey: SDL_Scancode,
            moveRightKey: SDL_Scancode,
            moveBottomKey: SDL_Scancode,
            moveLeftKey: SDL_Scancode,
            summonBomb: SDL_Scancode
        )
    ) {
        self.moveTopKey = arguments.moveTopKey
        self.moveRightKey = arguments.moveRightKey
        self.moveBottomKey = arguments.moveBottomKey
        self.moveLeftKey = arguments.moveLeftKey
        self.summonBomb = arguments.summonBomb
    }
}
