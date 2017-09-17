//
//  VideoBackgroundController.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/7/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class VideoBackgroundController: UIViewController {
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    
    override func viewDidLoad(){
        let theURL:URL = Bundle.main.url(forResource: "RhymeDiceIntro", withExtension: "mov")!
        
        avPlayer = AVPlayer(url:theURL)
        avPlayerLayer = AVPlayerLayer(player:avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .clear
        view.layer.insertSublayer(avPlayerLayer, at:0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name:NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object:avPlayer.currentItem)
    }
    
    @objc func playerItemDidReachEnd(notification:Notification){
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)
        avPlayer.play()
        paused = false
    }
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
        avPlayer.pause()
        paused = true
    }
}
