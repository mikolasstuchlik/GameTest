import Dispatch

extension DispatchTimeInterval {
    private enum DoubleInterval {
        case none
        case seconds(Double)
        case milliseconds(Double)
        case microseconds(Double)
        case nanoseconds(Double)
    }

    var prettyPrint: String {
        switch normalized() {
        case let .seconds(time):
            return "\(time) s"
        case let .milliseconds(time):
            return "\(time) ms"
        case let .microseconds(time):
            return "\(time) μs"
        case let .nanoseconds(time):
            return "\(time) ns"
        case .none:
            return "<none>"
        }
    }

    private func normalized() -> DoubleInterval {
        switch self {
        case .seconds(let time):
            return .seconds(Double(time))

        case .milliseconds(let time) where time / 1000 > 1 :
            return .seconds(Double(time) / 1000.0)
        case .milliseconds(let time) :
            return .milliseconds(Double(time))

        case .microseconds(let time) where time / 1000000 > 1 :
            return .seconds(Double(time) / 1000000.0)
        case .microseconds(let time) where time / 1000 > 1 :
            return .milliseconds(Double(time) / 1000.0)
        case .microseconds(let time) :
            return .microseconds(Double(time))

        case .nanoseconds(let time) where time / 1000000000 > 1 :
            return .seconds(Double(time) / 1000000000.0)
        case .nanoseconds(let time) where time / 1000000 > 1 :
            return .milliseconds(Double(time) / 1000000.0)
        case .nanoseconds(let time) where time / 1000 > 1 :
            return .microseconds(Double(time) / 1000.0)
        case .nanoseconds(let time) :
            return .nanoseconds(Double(time))
        default:
            return .none
        }
    }
}

#if os(Linux)

extension DispatchTime {
    func distance(to time: DispatchTime) -> DispatchTimeInterval {
        DispatchTimeInterval.nanoseconds(Int(time.uptimeNanoseconds - self.uptimeNanoseconds))
    }
}

#endif

func measure(_ named: String, _ block: () -> Void) {
    #if !MEASURE
        block()
    #else
    let startTime = DispatchTime.now()
    block()
    let endTime = DispatchTime.now()
    report(name: named, measured: startTime.distance(to: endTime).prettyPrint)
    #endif
}

func report(name: String, measured: String) {
    #if MEASURE
    DispatchQueue.global(qos: .userInteractive).async {
        print(String(
            format:"Reporting: %@%@%@", 
            name, 
            String(repeating: " ", count: max(1, 30 - name.count)), 
            measured
        ))
    }
    #endif
}