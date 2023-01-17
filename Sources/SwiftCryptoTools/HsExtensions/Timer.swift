import Foundation

public extension Timer {

    @discardableResult static func fireAfter(_ interval: TimeInterval, repeats: Bool = false,  runLoopModes: RunLoop.Mode = RunLoop.Mode.common, action: (() -> ())? = nil) -> Timer {
        let actionTimer = ActionTimer()
        actionTimer.action = action

        let timer = Timer(fireAt: Date(timeIntervalSinceNow: interval), interval: interval, target: actionTimer, selector: #selector(actionTimer.timerEvent), userInfo: nil, repeats: repeats)
        RunLoop.main.add(timer, forMode: runLoopModes)

        return timer
    }

}

fileprivate class ActionTimer {

    var action: (() -> ())?

    @objc func timerEvent() {
        action?()
    }

//    deinit {
//        print("deinit \(self)")
//    }

}
