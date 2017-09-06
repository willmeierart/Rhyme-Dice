//
//  ViewController.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/5/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class DiceController: UIViewController {
    
    var player:AVAudioPlayer = AVAudioPlayer()
    
    @IBAction func play(_ sender: Any) {
        player.play()
    }
    
    @IBAction func pause(_ sender: Any) {
        player.pause()
    }
    
    @IBAction func replay(_ sender: Any) {
        player.currentTime = 0
    }
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var leftDie: UIImageView!
    @IBOutlet weak var rightDie: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        do
        {
            let audioPath = Bundle.main.path(forResource: "Wipe Me Down", ofType: "mp3")
            try player = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
        }
        catch
        {
            
        }
        getSongs()
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
    
    func getSongs(){
        let folderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        
        do{
            let songPath = try FileManager.default.contentsOfDirectory(at:folderURL, includingPropertiesForKeys:nil, options: .skipsHiddenFiles)
            
            for song in songPath{
                var mySong = song.absoluteString
                if mySong.contains(".mp3"){
                    let findString = mySong.components(separatedBy: "/")
                    mySong = findString[findString.count-1]
                    mySong = mySong.replacingOccurrences(of: "%20", with: " ")
                    mySong = mySong.replacingOccurrences(of: ".mp3", with: "")
                    print(mySong)
                }
            }
        }
        catch{
            
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

