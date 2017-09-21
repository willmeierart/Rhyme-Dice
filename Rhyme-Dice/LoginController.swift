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

//var AppData:[String:Any]!

class LoginController: UIViewController, FBSDKLoginButtonDelegate {
    
    var appData:[String:Any] = [:]
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
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
        
        
//        let myLoginButton = UIButton(type: .custom)
//        myLoginButton.backgroundColor = UIColor.red
//        myLoginButton.frame = CGRect(x: self.view.frame.width/2-100, y:20, width:200, height:28)
//        myLoginButton.center = view.center;
//        myLoginButton.setTitle("Login with FB", for: .normal)
//        myLoginButton.addTarget(self,  action: #selector(self.loginButtonClicked), for: .touchUpInside)
//        view.addSubview(myLoginButton)
        
        let loginButton = FBSDKLoginButton()
        loginButton.frame = CGRect(x: self.view.frame.width/2-100, y:20, width:200, height:30)
        loginButton.readPermissions = ["user_friends", "public_profile", "email"]
        loginButton.delegate = self
        view.addSubview(loginButton)
        
        if let token = FBSDKAccessToken.current() {
            fetchProfile()
        }
    }
    
//    let mypermission = FBSDKGraphRequest(graphPath: "me/permissions/", parameters: nil, HTTPMethod: "DELETE")
//    mypermission.startWithCompletionHandler({(connection,result,error)-> Void in
//    print("Success")
//    // in here call your login action method, it called every time user login permission
//
//    })
    
    func fetchProfile(){
        
        
        var fbID:String = ""
        var email:String = ""
        var picture:String = ""
        var friends:[NSObject] = []
        
        let parameters = ["fields":"email,name,friends,picture.type(normal)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).start {(connection, result, error) -> Void in
            if error != nil {
                print(error!)
                return
            }
            guard let Result = result as? [String:Any] else { return }
         
            let Email = Result["email"] as! String
            let id = Result["id"] as! String
            let pic = Result["picture"] as! NSDictionary, picData = pic["data"] as! NSDictionary, picURL = picData["url"] as! String
            let friendz = Result["friends"] as! NSDictionary, friendsData = friendz["data"] as! [NSObject]
            fbID = id
            email = Email
            picture = picURL
            friends = friendsData
            self.appData = ["id":fbID, "email":email, "picture":picture, "friends":friends]
            UserDefaults.standard.set(self.appData, forKey: "AppData")
            self.loginViewSegue()
        }
        
    }
    func loginViewSegue(){
        RecordingsDataManager.updateAllDataFromServer()
        DispatchQueue.main.asyncAfter(deadline: .now()){
            
            self.performSegue(withIdentifier: "LoginSegue", sender: self)
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        fetchProfile()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LoginSegue" {
            if let destination = segue.destination as? DiceController {
                destination.appData = self.appData
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out")
//        FBSDKAccessToken.setValue(nil, forKey:"token")
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
