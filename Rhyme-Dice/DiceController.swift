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

class DiceController: UIViewController, AVAudioRecorderDelegate
//    UIDragInteractionDelegate
{
    

    
    
    var wordSets:[[String]]!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!

    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var nowPlaying: UILabel!
    
    @IBOutlet weak var label: UILabel!
    
    
    @IBOutlet weak var leftDie: UIImageView!
    @IBOutlet weak var rightDie: UIImageView!
    
    @IBOutlet weak var leftWordButton: UIButton!
    @IBOutlet weak var rightWordButton: UIButton!
    
    
    @IBOutlet weak var leftDieStack: UIStackView!
    @IBOutlet weak var leftDieStackContainerView: UIView!
    @IBOutlet weak var rightDieStack: UIStackView!
    @IBOutlet weak var rightDieStackContainerView: UIView!
    
    @IBOutlet weak var myVolumeViewParentView: UIView!
    
// IOS 11 THING:
    
    
//    func customEnableDragging(on view: UIView, dragInteractionDelegate: UIDragInteractionDelegate) {
//        let dragInteraction = UIDragInteraction(delegate: dragInteractionDelegate)
//        view.addInteraction(dragInteraction)
//    }
//    
//    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
//        // Cast to NSString is required for NSItemProviderWriting support.
//        let stringItemProvider = NSItemProvider(object: "Hello World" as NSString)
//        return [
//            UIDragItem(itemProvider: stringItemProvider)
//        ]
//    }
    
    
    
    
    
    
//    @IBAction func goToLibrary(_ sender: UITapGestureRecognizer) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "playlist")
//        self.present(vc, animated:true, completion:nil)
//        print(vc)
//    }
//    
    
    @IBAction func play(_ sender: Any) {
        if audioStuffed == true && audioPlayer.isPlaying == false{
            audioPlayer.play()
            nowPlaying.text = songs[thisSong]
        } else if audioStuffed == false{
            print(songs)
//            playThis(thisOne:songs[1])
        }
    }
    @IBAction func pause(_ sender: Any) {
        if audioStuffed == true && audioPlayer.isPlaying {
            nowPlaying.text = songs[thisSong]
            audioPlayer.pause()
        }
    }
    @IBAction func prev(_ sender: Any) {
        if audioStuffed == true && thisSong != 1 {
            playThis(thisOne: songs[thisSong-1])
            thisSong -= 1
            nowPlaying.text = songs[thisSong]
        } else {}
    }
    @IBAction func next(_ sender: Any) {
        if audioStuffed == true && thisSong < songs.count-1{
            playThis(thisOne: songs[thisSong+1])
            thisSong += 1
            nowPlaying.text = songs[thisSong]
        }else{}
    }
    
//USE MPVOLUMEVIEW
    @IBAction func volume(_ sender: UISlider) {
        if audioStuffed == true{
            audioPlayer.volume = sender.value
            print(sender.value)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        wordSets = []
        initWordButtons()
        
//        customEnableDragging()
        
        
        myVolumeViewParentView.backgroundColor = UIColor.clear
        let myVolumeView = MPVolumeView(frame: myVolumeViewParentView.bounds)
        myVolumeViewParentView.addSubview(myVolumeView)
        
        
        recordingSession = AVAudioSession.sharedInstance()
        try!recordingSession.setCategory(AVAudioSessionCategoryPlayback, with: AVAudioSessionCategoryOptions.mixWithOthers)
        
        if audioStuffed == true {
            nowPlaying.text = "Now Playing: \(songs[thisSong])"
        }
        
        
        
        do{
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission(){[unowned self] allowed in
                DispatchQueue.main.async{
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        //
                    }
                }
            }
        } catch {
            //
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        
    }
    
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        updateDice()
    }
    
    func loadRecordingUI(){
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
    }
    
    
    func playThis(thisOne:String){
        do{
            let audioPath = Bundle.main.path(forResource: thisOne, ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
        }catch{
            print("error")
        }
    }
    
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    func recordTapped(){
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success:true)
        }
    }
    func startRecording(){
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(Date()).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 2,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioPlayer.volume = 0.6
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            recordButton.setTitle("STOP", for: .normal)
        } catch {
            finishRecording(success:false)
        }
    }
    func finishRecording(success: Bool){
        audioRecorder.stop()
        audioRecorder = nil
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        
        if success {
            recordButton.setTitle("RECORD", for: .normal)
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
//            self.keepRecording()
//            print(self.title? as Any)
        }))
        
        
//        alert.addAction(UIAlertAction(title: "Edit", style: .`default`, handler: { action in
////            self.editRecording()
//            print(self.title!)
//        }))
        
        
        alert.addAction(UIAlertAction(title: "Discard", style: .`destructive`, handler: { action in
//            self.discardRecording()
//            print(self.title? as Any)
        }))
        
        present(alert, animated:true, completion: nil)
    }
    
    func keepRecording(){
        
    }
    func editRecording(){
        
    }
    func discardRecording(){
        
    }
    
    

    
    func updateDice(){
        let APIurl:String = "https://rhymedice.herokuapp.com/words/"
        
        let firstNumber = Int(arc4random_uniform(6)+1)
        let secondNumber = Int(arc4random_uniform(6)+1)
        
        let shortSounds = [1:"a", 2:"eh", 3:"i", 4:"o", 5:"ure", 6:"oo"]
        let longSounds = [1:"ay", 2:"ee", 3:"ie", 4:"oh", 5:"oy", 6:"uh"]
        
        let sound1 = longSounds[firstNumber]!
        let sound2 = shortSounds[secondNumber]!
        
        asyncGetBothWordSets(url: APIurl, sounds: [sound1, sound2], numbers:[firstNumber, secondNumber])
        
//        DispatchQueue.main.asyncAfter(deadline: .now()){
//            print(self.wordSets)
//        }
    }
    
    func animateRoll(die:UIImageView!, imgSet:String){
        die.animationImages = (1..<6).map{UIImage(named:"Dice\(imgSet)\($0)")!}
        die.animationDuration = 1.0
        die.animationRepeatCount = 1
        die.startAnimating()
    }
    
    
    func asyncGetBothWordSets(url:String, sounds:[String], numbers:[Int]){
        wordSets = []
        getWords(url:url, sound:sounds[0], completion:{response in
            let arr = self.appendSetsArray(json:response, sound:sounds[0])
            self.wordSets.append(arr)
            self.getWords(url:url, sound:sounds[1], completion:{response in
                let arr = self.appendSetsArray(json:response, sound:sounds[1])
                self.wordSets.append(arr)
                self.displayDiceData(numbers: numbers)
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
    
    func displayDiceData(numbers:[Int]){
        if wordSets.count > 0 {
            let sound1:String = getRandomWordFromSet(set: wordSets[0])
            let sound2:String = getRandomWordFromSet(set: wordSets[1])
            
            leftWordButton.setTitle("\(sound1)", for: .normal)
            rightWordButton.setTitle("\(sound2)", for: .normal)
            
            DispatchQueue.main.asyncAfter(deadline: .now()){
                self.animateRoll(die:self.leftDie, imgSet:"Long")
                self.animateRoll(die:self.rightDie, imgSet:"Short")
            }
            
            leftDie.image = UIImage(named: "DiceLong\(numbers[0])")
            rightDie.image = UIImage(named: "DiceShort\(numbers[1])")

        }
           }
    
    func getRandomWordFromSet(set:[String])->String{
        if set.count > 0 {
            let index = Int(arc4random_uniform(UInt32(set.count) - 1))
            print(index)
            return set[index]
        } else {
            return "fuck"
        }
    }
    
    func initWordButtons(){
        leftWordButton.addTarget(self, action: #selector(swapLeftWord), for: .touchUpInside)
        rightWordButton.addTarget(self, action: #selector(swapRightWord), for: .touchUpInside)
    }
    func swapLeftWord(){
        if wordSets.count > 0{
            let newSound = getRandomWordFromSet(set: wordSets[0])
            leftWordButton.setTitle("\(newSound)", for: .normal)
        }
    }
    func swapRightWord(){
        if wordSets.count > 0{
            let newSound = getRandomWordFromSet(set: wordSets[1])
            rightWordButton.setTitle("\(newSound)", for: .normal)
        }
    }
}

