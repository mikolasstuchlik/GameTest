let game = Application()

try game.startWindow(
    title: "Fish pond", 
    dimension: AxisRect(x: 100, y: 100, width: 1152, height: 768), 
    fullscreen: false
)

let frameCap = FrameCapCount(frameCap: 120)
var rtcCounter = PassedTimeCount()

while game.isRunning {
    frameCap.delayAfter {
        let events = game.handleEvents()
        let (currentTime, delatInMs) = rtcCounter.nextFrame()
        game.update(
            currentTime: currentTime,
            timePassedInMs: delatInMs, 
            events: events
        )
        try! game.render()
    }
}

game.clean()
