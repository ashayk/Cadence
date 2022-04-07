//
//  UserDefaultsExtension.swift
//  Cadence WatchKit Extension
//
//  Created by Alex Shaykevich on 7/4/2022.
//

import Foundation

extension UserDefaults {
    
    static let MAX_TABLE_BPM : Int = 200
    static let MIN_TABLE_BPM : Int = 80
    static let UPPER_FEEDBACK_BPM : Int = 10
    static let LOWER_FEEDBACK_BPM : Int = 1
    static let METRONOME_GRACE_PERIOD : Double = 5.0

    private static let FEEDBACK_BPM_KEY : String = "feedbackbpmkey"
    private static let WT_SHOWN_KEY : String = "walkthroughshownkey"
    private static let CADENCE_BPM_KEY : String = "cadencebpmkey"
    private static let DEFAULT_FEEDBACK_BPM : Int = 3
    private static let DEFAULT_CADENCE_BPM : Int = 170
    
    static func initDefaults() {
        UserDefaults.standard.register(defaults: [
            UserDefaults.FEEDBACK_BPM_KEY: UserDefaults.DEFAULT_FEEDBACK_BPM,
            UserDefaults.CADENCE_BPM_KEY: UserDefaults.DEFAULT_CADENCE_BPM,
            UserDefaults.WT_SHOWN_KEY : false
        ])
    }
    
    var feedbackBPM : Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.FEEDBACK_BPM_KEY)
        }
        get {
            return UserDefaults.standard.integer(forKey: UserDefaults.FEEDBACK_BPM_KEY)
        }
    }
    
    var cadenceBPM : Int {
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.CADENCE_BPM_KEY)
        }
        get {
            return UserDefaults.standard.integer(forKey: UserDefaults.CADENCE_BPM_KEY)
        }
    }
    
    var wtShown : Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.WT_SHOWN_KEY)
        }
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.WT_SHOWN_KEY)
        }
    }
    
}
