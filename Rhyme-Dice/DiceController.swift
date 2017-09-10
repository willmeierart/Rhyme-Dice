//
//  DiceController.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/5/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

//import Foundation
import AVFoundation
import UIKit

class DiceController: UIViewController, AVAudioRecorderDelegate {
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var nowPlaying: UILabel!
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var leftDie: UIImageView!
    @IBOutlet weak var rightDie: UIImageView!
    
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
        
        if audioStuffed == true {
            nowPlaying.text = "Now Playing: \(songs[thisSong])"
        }
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do{
//            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    func finishRecording(success: Bool){
        audioRecorder.stop()
        audioRecorder = nil
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {}
        
        if success {
            recordButton.setTitle("RECORD", for: .normal)
        }
    }
    func recordTapped(){
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success:true)
        }
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    
    func updateDice(){
        let firstNumber = Int(arc4random_uniform(6)+1)
        let secondNumber = Int(arc4random_uniform(6)+1)
        
        let shortSounds = [1:"fat", 2:"head", 3:"thick", 4:"hot", 5:"luck", 6:"wood"]
        let longSounds = [1:"stay", 2:"sweet", 3:"bite", 4:"float", 5:"boy", 6:"again"]
        
        self.label.text = "spit bars rhymin with \(longSounds[firstNumber]!) n \(shortSounds[secondNumber]!)"
        
        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.animateRoll(die:self.leftDie, imgSet:"Long")
            self.animateRoll(die:self.rightDie, imgSet:"Short")
        }
        
        leftDie.image = UIImage(named: "DiceLong\(firstNumber)")
        rightDie.image = UIImage(named: "DiceShort\(secondNumber)")
    }
    func animateRoll(die:UIImageView!, imgSet:String){
        die.animationImages = (1..<6).map{UIImage(named:"Dice\(imgSet)\($0)")!}
        die.animationDuration = 1.0
        die.animationRepeatCount = 1
        die.startAnimating()
    }
}

