//
//  Cloud.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/18/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import Foundation
import UIKit

class Cloud {
    static func generate() -> UIImage{
    func randomInt(lower: Int, upper: Int) -> Int {
        assert(lower < upper)
        return lower + Int(arc4random_uniform(UInt32(upper - lower)))
    }
    
    func circle(at center: CGPoint, radius: CGFloat) -> UIBezierPath {
        return UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
    }
    
    let a = Double(randomInt(lower: 70, upper: 100))
    let b = Double(randomInt(lower: 10, upper: 35))
    let ndiv = 12 as Double
    
    let points = stride(from: 0.0, to: 1.0, by: 1/ndiv).map { CGPoint(x: a * cos(6.28 * $0), y: b * sin(6.28 * $0)) }
    
    let path = UIBezierPath()
    path.move(to: points[0])
    for point in points[1..<points.count] {
        path.addLine(to: point)
    }
    path.close()
    
    let minRadius = (Int)(Double.pi * a/ndiv)
    let maxRadius = minRadius + 25
    
    for point in points[1..<points.count] {
        let randomRadius = CGFloat(randomInt(lower: minRadius, upper: maxRadius))
        let circ = circle(at: point, radius: randomRadius)
        path.append(circ)
    }
    
    let (width, height) = (path.bounds.width, path.bounds.height)
    let margin = CGFloat(20)
    UIGraphicsBeginImageContext(CGSize(width: path.bounds.width + margin, height:path.bounds.height + margin))
    UIColor.white.setFill()
    path.apply(CGAffineTransform(translationX: width/2 + margin/2, y: height/2 + margin/2))
    path.fill()
    let im = UIGraphicsGetImageFromCurrentImageContext()
    return im!
    }
}
