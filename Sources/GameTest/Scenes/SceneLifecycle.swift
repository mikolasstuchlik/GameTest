protocol Scene {
    func willAssumeWindow()
    func assumedWindow()

    func willResignWindow()
    func resignedWindow()
}

extension Scene {
    func willAssumeWindow() { }
    func assumedWindow() { }

    func willResignWindow() { }
    func resignedWindow() { }
}