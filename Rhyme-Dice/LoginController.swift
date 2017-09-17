//
//  LoginController.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/17/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import FBSDKCoreKit
import FBSDKLoginKit

class LoginController: UIViewController, FBSDKLoginButtonDelegate {
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        loginButton.frame = CGRect(x: self.view.frame.width/2-100, y:20, width:200, height:30)
//        loginButton.center = view.center
        loginButton.readPermissions = ["user_friends", "public_profile", "email"]
        loginButton.delegate = self
        view.addSubview(loginButton)
        
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
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print (error)
        } else if result.isCancelled {
            print("User has cancelled")
        } else {

            performSegue(withIdentifier: "loginSegue", sender: nil)
            
            if result.grantedPermissions.contains("email"){
                if let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"]){
                    graphRequest.start(completionHandler: {(connection, result, error) in
                        if error != nil {
                            print(error!)
                        } else {
                            if let userDeets = result {
                                print(userDeets)
                            }
                        }
                    })
                }
            }
        }
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out")
    }
    
    @objc func playerItemDidReachEnd(notification:Notification){
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }
}
