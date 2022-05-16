import CLibs

let game = Application()

try game.startWindow(
    title: "Fish pond", 
    dimension: Rect(x: 100, y: 100, width: 800, height: 640), 
    fullscreen: false
)

let player = Entity()
try! player.assign(
    component: MovableObjectComponent.self, 
    arguments: (
        positionCenter: .zero,
        squareRadius: Size(width: 32, height: 32),
        categoryBitmask: 0,
        collisionBitmask: 0,
        notificationBitmask: 0,
        velocity: .zero, 
        maxVelocity: 1.0
    )
)
try! player.assign(
    component: SpriteComponent.self, 
    arguments: (asset: .fish, size: Size(width: 64, height: 64))
)
try! player.assign(
    component: ControllerComponent.self, 
    arguments: (
        moveTopKey: SDL_SCANCODE_W, 
        moveRightKey: SDL_SCANCODE_D, 
        moveBottomKey: SDL_SCANCODE_S, 
        moveLeftKey: SDL_SCANCODE_A
    )
)

let evilPlayer = Entity()
try! evilPlayer.assign(
    component: MovableObjectComponent.self, 
    arguments: (
        positionCenter: Point(x: 20, y: 20), 
        squareRadius: Size(width: 32, height: 32), 
        categoryBitmask: 0,
        collisionBitmask: 0,
        notificationBitmask: 0,
        velocity: Vector(x: 1, y: 0), 
        maxVelocity: 10.0
    )
)
try! evilPlayer.assign(
    component: SpriteComponent.self, 
    arguments: (asset: .evilFish, size: Size(width: 64, height: 64))
)

let frameCap: UInt32 = 240
let frameDelay: UInt32 = 1000 / frameCap

while game.isRunning {
    let frameStart = SDL_GetTicks()

    let events = game.handleEvents()
    game.update(events: events)
    try game.render()

    let frameTime = SDL_GetTicks() - frameStart

    if frameDelay > frameTime {
        SDL_Delay(frameDelay - frameTime)
    }
}

game.clean()