//
//  DiceController.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/5/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import SwiftyJSON
import Alamofire
import MediaPlayer
import AWSCore
import AWSCognito
import AWSS3

//@available(iOS 11.0, *)

class DiceController: UIViewController, AVAudioRecorderDelegate, UIDragInteractionDelegate{
    
    var appData:[String:Any]?
    
    var wordSets:[[String]]!
    var audioName:String!
    var audioFilePath:URL!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!

    @IBOutlet weak var leftWordButton: UIButton!
    @IBOutlet weak var rightWordButton: UIButton!
    
    @IBOutlet weak var leftDie: UIImageView!
    @IBOutlet weak var rightDie: UIImageView!
    @IBOutlet weak var leftDieStack: UIStackView!
    @IBOutlet weak var leftDieStackContainerView: UIView!
    @IBOutlet weak var rightDieStack: UIStackView!
    @IBOutlet weak var rightDieStackContainerView: UIView!
    
    @IBOutlet weak var myVolumeViewParentView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var topBar: UIView!
    
    
    
// IOS 11 THING:
    func customEnableDragging(on view: UIView, dragInteractionDelegate: UIDragInteractionDelegate) {
        let dragInteraction = UIDragInteraction(delegate: dragInteractionDelegate)
        view.addInteraction(dragInteraction)
    }

    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        // Cast to NSString is required for NSItemProviderWriting support.
        let stringItemProvider = NSItemProvider(object: "Hello World" as NSString)
        return [
            UIDragItem(itemProvider: stringItemProvider)
        ]
    }

    @IBAction func play(_ sender: Any) {
        Player.Play(button: playButton)
    }
    @IBAction func prev(_ sender: Any) {
        Player.Prev()
    }
    @IBAction func next(_ sender: Any) {
        Player.Next()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let cloud1 = Cloud.generate()
        let cloud2 = Cloud.generate()
        
        leftWordButton.setBackgroundImage(cloud1, for:.normal)
        rightWordButton.setBackgroundImage(cloud2, for:.normal)
        
        leftWordButton.layer.shadowColor = UIColor.black.cgColor
        leftWordButton.layer.shadowOpacity = 0.75
        leftWordButton.layer.shadowOffset = CGSize(width:0, height:3.0)
        leftWordButton.layer.shadowRadius = 10
        rightWordButton.layer.shadowColor = UIColor.black.cgColor
        rightWordButton.layer.shadowOpacity = 0.75
        rightWordButton.layer.shadowOffset = CGSize(width:0, height:3.0)
        rightWordButton.layer.shadowRadius = 10
        rightWordButton.titleLabel?.textAlignment = NSTextAlignment.center
        leftWordButton.titleLabel?.textAlignment = NSTextAlignment.center
        rightWordButton.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        leftWordButton.titleLabel?.font = UIFont(name:"HelveticaNeue-Bold", size: 16.0)
        
        leftDie.layer.shadowColor = UIColor.black.cgColor
        leftDie.layer.shadowOpacity = 1
        leftDie.layer.shadowOffset = CGSize(width:0, height:8.0)
        leftDie.layer.shadowRadius = 10
        rightDie.layer.shadowColor = UIColor.black.cgColor
        rightDie.layer.shadowOpacity = 1
        rightDie.layer.shadowOffset = CGSize(width:0, height:8.0)
        rightDie.layer.shadowRadius = 10
        
        recordButton.layer.shadowColor = UIColor.black.cgColor
        recordButton.layer.shadowOpacity = 1
        recordButton.layer.shadowOffset = CGSize.zero
        recordButton.layer.shadowRadius = 4
        
        topBar.layer.shadowColor = UIColor.black.cgColor
        topBar.layer.shadowOpacity = 0.5
        topBar.layer.shadowOffset = CGSize(width:0, height:4.0)
        topBar.layer.shadowRadius = 4
        
        wordSets = []
        
        initWordButtons()
        
        initWordFetching(forceWords: ["oh", "i"])
        
        myVolumeViewParentView.backgroundColor = UIColor.clear
        let myVolumeView = MPVolumeView(frame: myVolumeViewParentView.bounds)
        myVolumeViewParentView.addSubview(myVolumeView)
        
        
        recordingSession = AVAudioSession.sharedInstance()
        try!recordingSession.setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
        do{
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission(){[weak self] allowed in
                DispatchQueue.main.async{
                    if allowed {
                        if let strongSelf = self {
                            self!.loadRecordingUI()
                        }
                    } else {}
                }
            }
        } catch {}
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
//    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
//        updateDice()
//    }
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        updateDice()
    }
    
    func loadRecordingUI(){
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    @objc func recordTapped(){
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success:true)
        }
    }
    func startRecording(){
        let date = "\(Date())"
        let nameArr = date.components(separatedBy: " ")
        audioName = "\(nameArr[0])\(nameArr[1])"
        
        audioFilePath = getDocumentsDirectory().appendingPathComponent("\(audioName!).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            audioRecorder = try AVAudioRecorder(url: audioFilePath, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setImage(UIImage(named:"recButton3b"), for: .normal)
        } catch {
            finishRecording(success:false)
        }
    }
    func finishRecording(success: Bool){
        audioRecorder.stop()
        audioRecorder = nil
//        audioPlayer()
        
        if audioPlayer.isPlaying {
            audioPlayer.pause()
        }
        
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        if success {
            recordButton.setImage(UIImage(named:"recButton3a"), for: .normal)
            alertFinishedRecording()
        }
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func alertFinishedRecording(){
        let alert = UIAlertController(title: "Recording finished", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Keep", style: .`default`, handler: { action in
            self.keepRecording()
        }))

        alert.addAction(UIAlertAction(title: "Discard", style: .`destructive`, handler: { action in
            self.discardRecording()
        }))
        present(alert, animated:true, completion: nil)
    }
    
    func keepRecording(){
        nameRecording()
    }

    func discardRecording(){
        try! FileManager.default.removeItem(at: audioFilePath)
    }
    
    func nameRecording(){
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Name Recording",
                                            message: nil,
                                            preferredStyle: .alert)
        alertController!.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "\(self.audioName!)"
        })
        let action = UIAlertAction(title: "Save",
                                   style:UIAlertActionStyle.default,
                                   handler: {[weak self]
                                    (paramAction:UIAlertAction!) in
            if let textFields = alertController?.textFields{
                let theTextFields = textFields as [UITextField]
                let enteredText = theTextFields[0].text
                
                let basePath = self!.audioFilePath!.deletingLastPathComponent()
                
                let newName = enteredText!.replacingOccurrences(of: " ", with: "%20")
                
                let newFilePath:URL = URL(string:"\(basePath)\(newName).m4a")!
                
                do {
                    try FileManager.default.moveItem(at: self!.audioFilePath!, to: newFilePath)
                    self!.audioFilePath = newFilePath
                    DispatchQueue.main.asyncAfter(deadline: .now()){
                        RecordingsDataManager.uploadToAWS(file:self!.audioFilePath!)
                    }
                } catch {print(error)}
            }
        })
                            
        alertController?.addAction(action)
        self.present(alertController!, animated:true, completion:nil)
    }
    
    func updateDice(){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        initWordFetching(forceWords: [])
    }
    
    func initWordFetching(forceWords:[String]?){
        
        let firstNumber = Int(arc4random_uniform(12)+1)
        var secondNumber = Int(arc4random_uniform(12)+1)
        if secondNumber == firstNumber {
            secondNumber = Int(arc4random_uniform(12)+1)
        }
        
        let sounds = [1:"a", 2:"eh", 3:"i", 4:"o", 5:"ure", 6:"oo", 7:"ay", 8:"ee", 9:"ie", 10:"oh", 11:"oy", 12:"uh"]
        
        let sound1 = (forceWords?.isEmpty)! ? sounds[firstNumber]! : forceWords![0]
        let sound2 = (forceWords?.isEmpty)! ? sounds[secondNumber]! : forceWords![1]
        
         asyncGetBothWordSets(sounds: [sound1, sound2], soundSet:sounds)
    }
    
    func asyncGetBothWordSets(sounds:[String], soundSet:[Int:String]){
        let APIurl:String = "https://rhymedice.herokuapp.com/words/"
        wordSets = []
        getWords(url:APIurl, sound:sounds[0], completion:{response in
            let arr = self.appendSetsArray(json:response, sound:sounds[0])
            self.wordSets.append(arr)
            self.getWords(url:APIurl, sound:sounds[1], completion:{response in
                let arr = self.appendSetsArray(json:response, sound:sounds[1])
                self.wordSets.append(arr)
                self.displayDiceData(sounds:sounds, soundSet:soundSet)
            })
        })
    }
    
    func getWords(url:String, sound:String, completion: @escaping (_ success: JSON) -> Void){
        let URL = "\(url)\(sound)"
        var arr:[String] = []
        
        Alamofire.request(URL, method: .get, parameters:["sound":sound]).responseJSON{ response in
            if response.result.isSuccess {
                let wordJSON:JSON = JSON(response.result.value!)
                 completion(wordJSON)
            } else {
                print("Error \(String(describing: response.result.error))")
                arr.append(sound)
                self.wordSets.append([sound])
            }
        }
    }
    
    func appendSetsArray(json:JSON, sound:String) -> [String]{
        var arr:[String] = []
        for word in json["word"].arrayValue {
            let Word = word[sound].stringValue
            arr.append(Word)
        }
        return arr
    }
    
    func displayDiceData(sounds:[String], soundSet:[Int:String]){
        if wordSets.count > 0 {
            let sound1:String = getRandomWordFromSet(set: wordSets[0])
            let sound2:String = getRandomWordFromSet(set: wordSets[1])
            
            leftWordButton.setTitle(" \(sound1) ", for: .normal)
            rightWordButton.setTitle(" \(sound2) ", for: .normal)
            
            DispatchQueue.main.asyncAfter(deadline: .now()){
                self.animateRoll(die:self.leftDie, sounds:soundSet)
                self.animateRoll(die:self.rightDie, sounds:soundSet)
            }
            
            leftDie.image = UIImage(named: "Dice-\(sounds[0])")
            rightDie.image = UIImage(named: "Dice-\(sounds[1])")
        }
    }

    func animateRoll(die:UIImageView!, sounds:[Int:String]){
        let randomNumArr = (1..<12).map{_ in Int(arc4random_uniform(12)+1)}
        
        die.animationImages = randomNumArr.map{
            let thisSound = sounds[$0]
//            print(thisSound!)
            return UIImage(named:"Dice-\(thisSound!)")!
        }
        die.animationDuration = 1.0
        die.animationRepeatCount = 1
        die.startAnimating()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        
        let cloud1 = Cloud.generate()
        leftWordButton.setBackgroundImage(cloud1, for:.normal)
        let cloud2 = Cloud.generate()
        rightWordButton.setBackgroundImage(cloud2, for:.normal)
    }
    
    func getRandomWordFromSet(set:[String])->String{
        if !set.isEmpty {
            let index = Int(arc4random_uniform(UInt32(set.count) - 1))
            return set[index]
        } else {
            return "😶"
        }
    }
    
    func initWordButtons(){
        leftWordButton.addTarget(self, action: #selector(swapLeftWord), for: .touchUpInside)
        rightWordButton.addTarget(self, action: #selector(swapRightWord), for: .touchUpInside)
    }
    @objc func swapLeftWord(){
        if !wordSets.isEmpty {
            let newSound = getRandomWordFromSet(set: wordSets[0])
            leftWordButton.setTitle(" \(newSound) ", for: .normal)
            let cloud = Cloud.generate()
            leftWordButton.setBackgroundImage(cloud, for:.normal)
            
        }
    }
    @objc func swapRightWord(){
        if !wordSets.isEmpty {
            let newSound = getRandomWordFromSet(set: wordSets[1])
            rightWordButton.setTitle(" \(newSound) ", for: .normal)
            let cloud = Cloud.generate()
            rightWordButton.setBackgroundImage(cloud, for:.normal)
        }
    }
}

