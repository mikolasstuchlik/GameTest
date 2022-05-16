import CSDL2

let game = Application()

try game.startWindow(
    title: "Fish pond", 
    dimension: Rect(x: 100, y: 100, width: 800, height: 640), 
    fullscreen: false
)

try! Map(loadFrom: .main).summonEntities()

EntityFactory.player(
    asset: .fish, 
    controllable: true, 
    position: Point(x: 32, y: 256), 
    squareRadius: Size(width: 32, height: 32), 
    collisionBitmask: 0b1, 
    initialVelocity: .zero
).developerLabel = "player"

EntityFactory.player(
    asset: .evilFish, 
    controllable: false, 
    position: .zero, 
    squareRadius: Size(width: 32, height: 32), 
    collisionBitmask: 0, 
    initialVelocity: Vector(x: 0.25, y: 0.25)
).developerLabel = "enemy"

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
