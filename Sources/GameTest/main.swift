import CSDL2

let game = Application()

try game.startWindow(
    title: "Fish pond", 
    dimension: Rect(x: 100, y: 100, width: 800, height: 640), 
    fullscreen: false
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
