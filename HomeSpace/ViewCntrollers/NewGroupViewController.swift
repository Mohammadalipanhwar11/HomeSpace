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
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var mainText: UITextView!
    @IBOutlet weak var recordBottomConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var recordCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewBottomConstriant: NSLayoutConstraint!
    @IBOutlet weak var recordConstraint: NSLayoutConstraint!
    
    var oldIndex:[Int]?
    var index1:Int = 0
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    
    private let viewModel = ViewModel()
    private var chronometer: Chronometer?
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bottomwWave.meteringLevelBarWidth = 5.0
        self.bottomwWave.meteringLevelBarInterItem = 2.0
        self.bottomwWave.meteringLevelBarCornerRadius = 0.0
        self.bottomwWave.gradientStartColor = .white
        self.bottomwWave.gradientEndColor = .black
        doneButton.cornerRadius = 20
        doneButton.isHidden = true
        endButton.isHidden = true
        self.mainText.delegate = self
        setupSpeech()
        
        
        mainText.becomeFirstResponder()
        
        self.viewModel.askAudioRecordingPermission()
        
        self.viewModel.audioMeteringLevelUpdate = { [weak self] meteringLevel in
            guard let self = self, self.bottomwWave.audioVisualizationMode == .write else {
                return
            }
            self.bottomwWave.add(meteringLevel: meteringLevel)
        }
        
        self.viewModel.audioDidFinish = { [weak self] in
            self?.bottomwWave.stop()
        }
    }
    
    
    
    
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        
        
        
        endButton.isHidden = true
        doneButton.isHidden = true
        
    }
    func textViewDidChange(_ textView: UITextView) {
        if mainText.text >= "type" {
            mainText.textColor = UIColor.white
            mainText.font = UIFont.boldSystemFont(ofSize: 17)
            mainText.text = ""
            mainText.cornerRadius = 3
            mainText.borderWidth = 3
            recordButton.isHidden = true
            doneButton.isHidden = false
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
        endButton.isHidden = false
        mainText.isHidden = false
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
            recordCenterConstraint.constant = 200
            recordConstraint.constant = -80
            textViewBottomConstriant.constant = -100
            self.recordButton.setImage(UIImage(named: "pause"), for: UIControl.State.normal)
        }
    }
    
    
    
    @IBAction func end(_ sender: Any) {
        self.chronometer?.stop()
        self.chronometer = nil
        
        if mainText.text != "type" && mainText.text != ""{
//            performSegue(withIdentifier: "groups", sender: self)
        }else{
            let alert = UIAlertController(title: "No Voice", message: "Please Say Someting to continoue", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { (action) in
                
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    @IBAction func back(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    @IBAction func done(_ sender: Any) {
        
        
        
        if mainText.text != "type" && mainText.text != ""{
            performSegue(withIdentifier: "backTo", sender: self)
        }else{
            let alert = UIAlertController(title: "No Text Found", message: "Please type Someting to continoue", preferredStyle: UIAlertController.Style.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel) { (action) in
                self.recordButton.isHidden = false
                self.endButton.isHidden = true
                self.doneButton.isHidden = true
                self.mainText.textColor = UIColor(red: 0, green: 150/255, blue: 255/255, alpha: 1)
                self.mainText.font = UIFont.boldSystemFont(ofSize: 40)
                self.view.endEditing(true)
                self.mainText.text = "type"
            }
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
        
        mainText.text = ""
        
        
    }
    

    
}




fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}
