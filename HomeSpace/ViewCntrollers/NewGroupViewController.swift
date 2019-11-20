//
//  NewGroupViewController.swift
//  HomeSpace
//
//  Created by Axiom123 on 23/07/2019.
//  Copyright © 2019 MohammadAli. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Speech
import SoundWave

class NewGroupViewController: UIViewController,UITextViewDelegate,SFSpeechRecognizerDelegate {
    
    
    @IBOutlet weak var bottomwWave: AudioVisualizationView!
    @IBOutlet weak var _doneButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var endBtn: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var mainText: UITextView!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var mainTextHeight: NSLayoutConstraint!
    
    var groupText:String?
    var oldIndex:[Int]?
    var index1:Int = 0
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    var taskText:String!
    
    let delegate = UIApplication.shared.delegate as! AppDelegate
    
    private let viewModel = ViewModel()
    private var chronometer: Chronometer?
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self._doneButton.isHidden = false
        self.backBtn.isHidden = true
        
        self.bottomwWave.gradientStartColor = .white
        self.bottomwWave.gradientEndColor = .black
        doneButton.cornerRadius = 20
        doneButton.isHidden = true
        endBtn.isHidden = true
        self.mainText.delegate = self
        setupSpeech()
        
        mainText.becomeFirstResponder()
        
        self.viewModel.askAudioRecordingPermission()
        
        self.viewModel.audioMeteringLevelUpdate = { [weak self] meteringLevel in
            guard let self = self, self.bottomwWave.audioVisualizationMode == .write else {
                return
            }
            if meteringLevel > 0.012{
                let mtrLvl = meteringLevel * 14
                self.bottomwWave.add(meteringLevel: mtrLvl)
            }else{
                self.bottomwWave.add(meteringLevel: meteringLevel)
            }
        }
        
        self.viewModel.audioDidFinish = { [weak self] in
            self?.bottomwWave.stop()
        }
    NotificationCenter.default.addObserver(self, selector: #selector(editTaskViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(editTaskViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            
        }
        
        @objc func keyboardWillShow(notification: NSNotification) {
                guard let userInfo = notification.userInfo else {return}
                guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
                _ = keyboardSize.cgRectValue
                print(keyboardSize.cgRectValue.height)
                mainTextHeight.constant = keyboardSize.cgRectValue.height + 90
                self._doneButton.isHidden = false
                self.backBtn.isHidden = true
            }
            @objc func keyboardWillHide(notification: NSNotification) {
                guard notification.userInfo != nil else {return}
                mainTextHeight.constant = 180
                self._doneButton.isHidden = true
                self.backBtn.isHidden = false
            }
    func textViewDidBeginEditing(_ textView: UITextView) {
        endBtn.isHidden = true
        doneButton.isHidden = true
        
    }
    func textViewDidChange(_ textView: UITextView) {
        if mainText.text.count == 1{
            mainText.text = mainText.text.uppercased()
        }
        if mainText.text >= "Type" {
            self.mainText.borderColor = UIColor(red: 50/255, green: 150/255, blue: 247/255, alpha: 1.0)
            mainText.textColor = UIColor.white
            mainText.font = UIFont.boldSystemFont(ofSize: 17)
            let t = mainText.text
            print(t!.components(separatedBy: "Type"))
            if t!.components(separatedBy: "Type").count > 1{
                mainText.text = t!.components(separatedBy: "Type")[1]
            }
            mainText.cornerRadius = 3
            mainText.borderWidth = 3
            recordButton.isHidden = true
            doneButton.isHidden = false
            if mainText.text.count == 1{
                mainText.text = mainText.text.uppercased()
            }
        }else if mainText.text == ""{
            self.mainText.text = "Type"
            self.mainText.borderColor = .clear
            self.doneButton.isHidden = true
            self.recordButton.isHidden = false
        }
    }
    
    func setupSpeech() {
        
        self.recordButton.isEnabled = false
        self.speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.recordButton.isEnabled = isButtonEnabled
            }
        }
    }
    func startRecording() {
        
        // Clear all previous session data and cancel task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Create instance of audio session to record voice
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record, mode: AVAudioSession.Mode.measurement, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        self.recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        self.recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                var recordedText:String?
                recordedText = result?.bestTranscription.formattedString
                self.mainText.text = recordedText
                
                let range = NSMakeRange(self.mainText.text.count - 1, 0)
                self.mainText.scrollRangeToVisible(range)
                
                print(result?.bestTranscription.formattedString as Any)
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        self.audioEngine.prepare()
        
        do {
            try self.audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        print("Say something, I'm listening!")
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.recordButton.isEnabled = true
        } else {
            self.recordButton.isEnabled = false
        }
    }
    
    @IBAction func record(_ sender: Any) {
        
        mainText.endEditing(true)
        endBtn.isHidden = false
        mainText.isHidden = false
        
        self.mainText.text = ""
        
        self.mainTextHeight.constant = 190
        
        self.mainText.borderColor = UIColor(red: 50/255, green: 150/255, blue: 247/255, alpha: 1.0)
        if mainText.text >= "type" {
            mainText.textColor = UIColor.white
            mainText.font = UIFont.boldSystemFont(ofSize: 17)
            mainText.text = ""
        }
        
        if audioEngine.isRunning {
            self.chronometer?.pause()
            self.chronometer = nil
            do{
                try self.viewModel.pausePlaying()
            } catch {
                //                self.showAlert(with: error)
            }
            
            self.audioEngine.stop()
            self.recognitionRequest?.endAudio()
            self.recordButton.isEnabled = false
            //            self.recordButton.setTitle("Start Recording", for: .normal)
            self.recordButton.setImage(UIImage(named: "record"), for: UIControl.State.normal)
        } else {
            self.recordButton.isHidden = true
            self.bottomwWave.audioVisualizationMode = .write
            
            self.viewModel.startRecording { [weak self] soundRecord, error in
                if let error = error {
                    //                    self?.showAlert(with: error)
                    return
                }
                self?.chronometer = Chronometer()
                self?.chronometer?.start()
            }
            self.startRecording()
            self.mainText.cornerRadius = 3
            self.mainText.borderWidth = 3
//            self.recordButton.setImage(UIImage(named: "record"), for: UIControl.State.normal)
        }
    }
    
    
    
    @IBAction func end(_ sender: Any) {
        self.chronometer?.stop()
        self.chronometer = nil
        
        if mainText.text != "type" && mainText.text != ""{
            
            taskManager.shared.addTaskToNewGroup(mainText: mainText.text, taskText: self.taskText!)
            let controllers = self.navigationController?.viewControllers
            if let cont = controllers![controllers!.count-4] as? PageTabMenuViewController{
                self.navigationController?.popToViewController(cont, animated: true)                        }
            
        }else{
            successAlert(title: "message", msg: "Group name should not be empty", controller: self)
        }
        
    }
    @IBAction func back(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func done(_ sender: Any) {
        groupText = mainText.text
        if mainText.text != "type" && mainText.text != ""{
            
            taskManager.shared.addTaskToNewGroup(mainText: mainText.text, taskText: self.taskText!)
            
            let controllers = self.navigationController?.viewControllers
            if let cont = controllers![controllers!.count-4] as? PageTabMenuViewController{
                self.navigationController?.popToViewController(cont, animated: true)}
                
        }else{
            successAlert(title: "message", msg: "Group name should not be empty", controller: self)
        }
        
        mainText.text = ""
    }
}

fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
