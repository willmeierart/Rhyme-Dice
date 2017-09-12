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
import Alamofire
import SwiftyJSON

class DiceController: UIViewController, AVAudioRecorderDelegate {
    
    var wordSets:[[String]]!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!

    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var nowPlaying: UILabel!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var leftDie: UIImageView!
    @IBOutlet weak var rightDie: UIImageView!
    
    
    
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
            audioPlayer2.pause()
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
    @IBAction func volume(_ sender: UISlider) {
        if audioStuffed == true{
            audioPlayer.volume = sender.value
            print(sender.value)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        wordSets = []
        
        if audioStuffed == true {
            nowPlaying.text = "Now Playing: \(songs[thisSong])"
        }
        
        recordingSession = AVAudioSession.sharedInstance()
        
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
        let audioFilename = getDocumentsDirectory().appendingPathComponent( "\(Date()).m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
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
            print(self.title!)
        }))
//        alert.addAction(UIAlertAction(title: "Edit", style: .`default`, handler: { action in
////            self.editRecording()
//            print(self.title!)
//        }))
        alert.addAction(UIAlertAction(title: "Discard", style: .`destructive`, handler: { action in
//            self.discardRecording()
            print(self.title!)
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
        
        DispatchQueue.main.asyncAfter(deadline: .now()){
            print(self.wordSets)
        }

        
//        self.displayDiceData(numbers: [firstNumber,secondNumber])
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
            let arr = self.appendSetsArray(json:response[sounds[0]])
            self.wordSets.append(arr)
            self.getWords(url:url, sound:sounds[1], completion:{response in
                let arr = self.appendSetsArray(json:response[sounds[1]])
                self.wordSets.append(arr)
                self.displayDiceData(numbers: numbers, sounds: self.wordSets)
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
    
    func appendSetsArray(json:JSON) -> [String]{
        var arr:[String] = []
        for word in json {
            print(word)
            var Word = String(describing: word)
            let pattern = "(\", )"
            let regex = try! NSRegularExpression(pattern: pattern, options: [])
            let breaker = regex.matches(in: Word, range: NSMakeRange(0, Word.utf16.count))
            
            let Words = splitThatString(matches:breaker, toSearch:Word)
            Word = Words.last!
            Word = Word.replacingOccurrences(of: ")", with: "")
            Word = Word.replacingOccurrences(of: "\", ", with: "")
            arr.append(Word)
        }
        return arr
    }
    
    func displayDiceData(numbers:[Int], sounds:[[String]]){
        let index1 = Int(arc4random_uniform(UInt32(sounds[0].count)+1))
        let index2 = Int(arc4random_uniform(UInt32(sounds[1].count)+1))
        let sound1 = sounds[0][index1]
        let sound2 = sounds[1][index2]
        

        
        self.label.text = "spit bars rhymin with \(sound1) n \(sound2)"
        
        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.animateRoll(die:self.leftDie, imgSet:"Long")
            self.animateRoll(die:self.rightDie, imgSet:"Short")
        }
        
        leftDie.image = UIImage(named: "DiceLong\(numbers[0])")
        rightDie.image = UIImage(named: "DiceShort\(numbers[1])")
    }
    
    
    
    
    
    func splitThatString(matches:[NSTextCheckingResult], toSearch:String) -> [String]{
        let results = zip(matches, matches.dropFirst().map { Optional.some($0) } + [nil]).map { current, next -> String in
            let range = current.rangeAt(0)
            let start = String.UTF16Index(range.location)
            let end = next.map { $0.rangeAt(0) }.map { String.UTF16Index($0.location) } ?? String.UTF16Index(toSearch.utf16.count)
            
            return String(toSearch.utf16[start..<end])!
        }
        return results
    }
    
}

