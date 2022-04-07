//
//  InterfaceController.swift
//  Cadence WatchKit Extension
//
//  Created by Alex Shaykevich on 7/4/2022.
//

import WatchKit
import Foundation
import HealthKit
import CoreMotion
import AVFAudio

class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {
   
    var selectedRow : Int = -1
    var tableLoaded : Bool = false
    
    @IBOutlet weak var bpmPicker : WKInterfacePicker!
    @IBOutlet weak var startStopButton : WKInterfaceButton!
    @IBOutlet weak var  bpmLabel : WKInterfaceLabel!
    @IBOutlet weak var bpmImage : WKInterfaceImage!
    @IBOutlet weak var blGroup : WKInterfaceGroup!
    @IBOutlet weak var wtGroup : WKInterfaceGroup!
    
    lazy var healthStore : HKHealthStore = {
       HKHealthStore()
    }()
    
    var session : HKWorkoutSession?
    var  running : Bool = false
    var timer : DelayedTimer?
    var metronome : GracePeriodMetronome?
    var firstCadenceDetected : Bool = false
    var cadence : Double = -1
    var numbers : [UIImage] = []
    
    var counter : Int = 0
    var pedometer : CMPedometer?
    var animateWT : Bool = false

    override func awake(withContext context: Any?) {
        
        DispatchQueue.once(token: "com.custommedia.Cadence.init") {
            setPickerState()
            setupAudioSession()
            authoriseHealthKit { [weak self] (success: Bool, error : Error?) in
                guard let self = self, success else {
                    return
                }
                let _ : Bool = self.initPedometer()
                self.startStopButton.setEnabled(true)
                self.startStopButton.setBackgroundColor(.green)
            }
            
            if (UserDefaults.standard.wtShown == false) {
                self.startWTAnimation()
            }
            
            timer = DelayedTimer(delay: 0.5, completion: { [weak self] in
                guard let self = self else {
                    return
                }
                self.processBPM()
            })
            
            metronome = GracePeriodMetronome(gracePeriod: UserDefaults.METRONOME_GRACE_PERIOD)
            metronome?.bpm = Int32(UserDefaults.standard.cadenceBPM)
            metronome?.halveIt = false
        }
        
    }
    
    func setupAudioSession() {
        let sess : AVAudioSession = AVAudioSession.sharedInstance()
        try? sess.setCategory(.playback, options: [.duckOthers, .allowBluetoothA2DP])
    }
    
    func authoriseHealthKit(completion : @escaping ((Bool, Error?)->Void)) {
        
        if let type : HKQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            let readDataTypes : Set<HKSampleType> = Set([type])
            let writeDataTypes : Set<HKSampleType> = Set()
            healthStore.requestAuthorization(toShare: writeDataTypes, read: readDataTypes) { (success: Bool, error: Error?) in
                
                completion(success, error)
            }
        }
    }
    
    func startWTAnimation() {
        if(animateWT == false) {
            animateWT = true
            showHideWT(true)
        }
        self.blGroup.setHidden(false)
    }
    
    func stopWTAnimation() {
        if(self.animateWT == false) {
            return
        }
        self.animateWT = false
        
        self.animate(withDuration: 1.0, animations: { [weak self] in
            guard let self = self else {
                return
            }
            self.blGroup.setAlpha(0)
            self.wtGroup.setAlpha(0)
        })

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { [weak self ] _ in
            
            guard let self = self else {
                return
            }
            self.blGroup.setHidden(true)
            self.wtGroup.setHidden(true)
        })
        
    }
    
    func showHideWT(_ hide: Bool) {
        
        if(hide == false && self.animateWT == false) {
            return
        }
        
        let time : TimeInterval = 0.75
        self.animate(withDuration: time) { [weak self] in
            guard let self = self else {
                return
            }
            let alpha : CGFloat = hide ? 0 : 1
            self.wtGroup.setAlpha(alpha)
        }
    
        Timer.scheduledTimer(withTimeInterval: time, repeats: false) { [weak self] _ in
            guard let self = self else {
                return
            }
            if (self.animateWT) {
                self.showHideWT(!hide)
            }
        }
    }
    
    func processBPM() {
        let bpm : Int = UserDefaults.MIN_TABLE_BPM + selectedRow
        UserDefaults.standard.cadenceBPM = bpm
        self.metronome?.bpm = Int32(bpm)
    }
    
    func setPickerState() {
        
        numbers.removeAll()
        var items : [WKPickerItem] = []
        for i : Int in UserDefaults.MIN_TABLE_BPM...UserDefaults.MAX_TABLE_BPM {
            let item : WKPickerItem = WKPickerItem()
            let imgName : String = String(format: "numbers%d", i)
            let image : WKImage = WKImage(imageName: imgName)
            item.contentImage = image
            items.append(item)
            
            let uiImage : UIImage? = UIImage(named: imgName)
            if let uiImage : UIImage = uiImage {
                numbers.append(uiImage)
            }
        }
        bpmPicker.setItems(items)
        
        // set the target one
        self.selectRowFromCadence(cadence: UserDefaults.standard.cadenceBPM)
    }
    
    func selectRowFromCadence(cadence : Int) {
        let row : Int = max(0, cadence - UserDefaults.MIN_TABLE_BPM)
        selectedRow = row
        bpmPicker.setSelectedItemIndex(row)
        let image : UIImage = numbers[row]
        bpmImage.setImage(image)
    }
    
    @IBAction func pickerSelectedItemChanged(value: Int) {
        
        self.stopWTAnimation()
    
        if(running) {
            return
        }
        
        selectedRow = value
        self.timer?.start()
        if(value < self.numbers.count) {
            let im : UIImage = self.numbers[value]
            self.bpmImage.setImage(im)
        }
    }
    
    func initPedometer() -> Bool {
        self.pedometer = CMPedometer()
        let status : CMAuthorizationStatus = CMPedometer.authorizationStatus()
        return status == .authorized
    }

    @IBAction func startOrStop() {
        if(running) {
            running.toggle()
            self.metronome?.stop()
            try? AVAudioSession.sharedInstance().setActive(false, options: [])
            self.session?.stopActivity(with: Date.now)
            self.stopPedometer()
        } else {
            // delay setting running = YES until the workout has actually started in
            // case there are authorization errors
            self.startWorkout()
        }
    }
    
    func startWorkout() {
        self.authoriseHealthKit { [weak self] (success:Bool, error:Error?) in
            guard let self = self, success else {
                return
            }
            self.running = true
            self._startWorkout()
        }
    }
    
    func _startWorkout() {
        
        let configuration : HKWorkoutConfiguration = HKWorkoutConfiguration()
        configuration.activityType = .running
        session = try? HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        
        if (self.session == nil) {
            /// TODO: message to the user
        } else {
            session?.delegate = self
            session?.startActivity(with: Date.now)
            startPedometer()
        }
    }
    
    func startPedometer() {
        
        pedometer?.startUpdates(from: Date.now, withHandler: { [weak self] (pedometerData: CMPedometerData?, error:Error?) in
            
            guard let self = self else {
                return
            }
            
            if let _ = error, self.running {
                self.startOrStop()
                DispatchQueue.main.async {
                    let alert : WKAlertAction = WKAlertAction(title: "Ok", style: .cancel) {
                        //...
                    }
                    self.presentAlert(withTitle: "Permissions", message: "Please check permissions to allow detection of motion events.", preferredStyle: .alert, actions: [alert])
                }
                
                return
            }
            
            if let pedometerData = pedometerData, let bpm : Double = pedometerData.currentCadence?.doubleValue {

                self.cadence = bpm * 60.0
                self.bpmLabel.setText(String(format:"%li",round(self.cadence)))
                if(self.firstCadenceDetected) {
                    self.handleMetronome(cadence: self.cadence)
                }
                self.firstCadenceDetected = true
            }
            
        })
    }
    
    func handleMetronome(cadence: Double) {
        if(running) {
            let valid : Bool = Int(cadence) >= UserDefaults.standard.cadenceBPM - UserDefaults.standard.feedbackBPM && Int(cadence) <= UserDefaults.standard.cadenceBPM + UserDefaults.standard.feedbackBPM
            if(valid) {
                metronome?.stop()
                try? AVAudioSession.sharedInstance().setActive(false, options: [])
            } else {
                try? AVAudioSession.sharedInstance().setActive(true, options: [])
                metronome?.start()
            }
        }
    }
    
    func stopPedometer() {
        self.pedometer?.stopUpdates()
        self.pedometer?.stopEventUpdates()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        /// TODO
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        /// TODO
    }
    
}

