//
//  LoginController.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/17/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginController: UIViewController, FBSDKLoginButtonDelegate {
    
//    var loginButton: FBSDKLoginButton?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        let loginButton = FBSDKLoginButton()
        loginButton.center = view.center
        loginButton.readPermissions = ["user_friends", "public_profile", "email"]
        loginButton.delegate = self
        view.addSubview(loginButton)
    }
    override func viewDidDisappear(_ animated: Bool){
        super.viewDidDisappear(animated)
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print (error)
        } else if result.isCancelled {
            print("User has cancelled")
        } else {
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
}
