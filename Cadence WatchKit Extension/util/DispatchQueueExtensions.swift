//
//  DispatchQueueExtensions.swift
//  Cadence WatchKit Extension
//
//  Created by Alex Shaykevich on 7/4/2022.
//

import Foundation

extension DispatchQueue {

    private static var _onceTracker = [String]()

    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }

        if _onceTracker.contains(token) {
            return
        }

        _onceTracker.append(token)
        block()
    }
}
