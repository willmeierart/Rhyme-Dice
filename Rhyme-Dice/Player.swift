//
//  Player.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/19/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

var songs:[String] = []
var thisSong = 0
var audioStuffed = false

var audioPlayer = AVAudioPlayer()

class Player {

    static func loadNewSource(source:URL){
//        audioPlayer.url = source
        print(source)
        do {
            try audioPlayer = AVAudioPlayer(contentsOf: source)
        } catch {
            print(error)
        }
//        audioPlayer = AVAudioPlayer(contentsOf: source)
    }
    
    static func Play(button:UIButton) {
        if audioStuffed == true && audioPlayer.isPlaying == false{
            audioPlayer.play()
            button.setImage(UIImage(named:"playerPause"), for: .normal)
        } else if audioStuffed == true && audioPlayer.isPlaying == true{
            audioPlayer.pause()
            button.setImage(UIImage(named:"playerPlay"), for: .normal)
        } else {return}
    }
    static func Prev() {
        if audioStuffed == true && thisSong != 1 {
            self.playThis(thisOne: songs[thisSong-1])
            thisSong -= 1
        } else {}
    }
    static func Next() {
        if audioStuffed == true && thisSong < songs.count-1{
            self.playThis(thisOne: songs[thisSong+1])
            thisSong += 1
        }else{}
    }
    static func playThis(thisOne:String){
        do{
            let audioPath = Bundle.main.path(forResource: thisOne, ofType: ".mp3")
            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
            audioPlayer.play()
        }catch{
            print("error")
        }
    }
}



