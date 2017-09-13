//
//  ARController.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/12/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import Foundation
import UIKit

class ARController: UIViewController{
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.shouldRotate = true
        

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

}
