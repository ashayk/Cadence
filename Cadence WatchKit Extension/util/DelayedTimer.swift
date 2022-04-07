//
//  DelayedTimer.swift
//  Cadence WatchKit Extension
//
//  Created by Alex Shaykevich on 7/4/2022.
//

import Foundation

class DelayedTimer {
    
    private var completionHandler: (()->Void)?
    private var time : TimeInterval = 0
    private var lastTime : Double = -1.0
    private var delayedTimer : Timer?
    
    init(delay: TimeInterval = 0.5, completion : @escaping (()->Void)) {
        self.time = delay
        self.completionHandler = completion
    }
    
    func start() {
        let now : Double = CFAbsoluteTimeGetCurrent()
        stop()
        delayedTimer = Timer(timeInterval: time, target: self, selector: #selector(handleTimer), userInfo: nil, repeats: false)
        lastTime = now
    }
    
    func stop() {
        if let timer = delayedTimer {
            timer.invalidate()
        }
    }
    
    @objc private func handleTimer() {
        if let completion = completionHandler {
            completion()
        }
    }
    
}
