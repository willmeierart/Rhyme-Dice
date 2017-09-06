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

class DiceController: UIViewController {
    
//    var player:AVAudioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var nowPlaying: UILabel!
    
    @IBAction func play(_ sender: Any) {
        if audioStuffed == true && audioPlayer.isPlaying == false {
            audioPlayer.play()
        }
        
    }
    @IBAction func pause(_ sender: Any) {
        if audioStuffed == true && audioPlayer.isPlaying {
            audioPlayer.pause()
        }
        
    }
    @IBAction func prev(_ sender: Any) {
        if audioStuffed == true && thisSong > 0{
            playThis(thisOne: songs[thisSong-1])
            thisSong -= 1
            nowPlaying.text = songs[thisSong]
        } else {
            
        }
        
    }
    @IBAction func next(_ sender: Any) {
        if audioStuffed == true && thisSong < songs.count-1{
            playThis(thisOne: songs[thisSong+1])
            thisSong += 1
            nowPlaying.text = songs[thisSong]
        }else{
            
        }
        
    }
    @IBAction func volume(_ sender: UISlider) {
        audioPlayer.volume = sender.value
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
    
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var leftDie: UIImageView!
    @IBOutlet weak var rightDie: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if audioStuffed == true {
            nowPlaying.text = "Now Playing: \(songs[thisSong])"
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func rollButton(_ sender: Any) {
        updateDice()
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        updateDice()
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

