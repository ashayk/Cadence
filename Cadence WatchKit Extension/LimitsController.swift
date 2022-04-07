//
//  LimitsController.swift
//  Cadence WatchKit Extension
//
//  Created by Alex Shaykevich on 7/4/2022.
//
import WatchKit
import Foundation
import UIKit

class LimitsController : WKInterfaceController {
    
    @IBOutlet weak var bpmLabel : WKInterfaceLabel!
    @IBOutlet weak var upButton : WKInterfaceButton!
    @IBOutlet weak var downButton : WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        adjustBPMLabel()
    }
    
    @IBAction func upAction() {        
        let fBPM : Int = UserDefaults.standard.feedbackBPM + 1
        if(fBPM <= UserDefaults.UPPER_FEEDBACK_BPM) {
            UserDefaults.standard.feedbackBPM += 1
            adjustBPMLabel()
        }
    }
    
    @IBAction func downAction() {
        let fBPM : Int = UserDefaults.standard.feedbackBPM - 1
        if(fBPM >= UserDefaults.LOWER_FEEDBACK_BPM) {
            UserDefaults.standard.feedbackBPM -= 1
            adjustBPMLabel()
        }
    }
    
    private func adjustBPMLabel() {
        bpmLabel.setText(String(format: "± %i", UserDefaults.standard.feedbackBPM))
    }
}
