import CSDL2

let game = Application()

try game.startWindow(
    title: "Fish pond", 
    dimension: Rect(x: 100, y: 100, width: 800, height: 640), 
    fullscreen: false
)

let frameCap = FrameCapCount(frameCap: 120)
var rtcCounter = PassedTimeCount()

while game.isRunning {
    frameCap.delayAfter {
        let events = game.handleEvents()
        game.update(events: events, timePassedInMs: rtcCounter.nextFrame())
        try! game.render()
    }
}

game.clean()
