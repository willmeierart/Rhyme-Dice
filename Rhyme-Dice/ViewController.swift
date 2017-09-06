//
//  ViewController.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/5/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var leftDie: UIImageView!
    @IBOutlet weak var rightDie: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func rollButton(_ sender: Any) {
        let firstNumber = Int(arc4random_uniform(6) + 1)
        let secondNumber = Int(arc4random_uniform(6) + 1)
        
        label.text = "spit bars rhymin with n "
        leftDie.image = UIImage(named: "DiceLong\(firstNumber)")
        rightDie.image = UIImage(named: "DiceLong\(secondNumber)")
    }
    
}

