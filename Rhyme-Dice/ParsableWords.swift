//
//  ParsableWords.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/12/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import JSONParserSwift


class ParsableWords: ParsableModel {
    var word:Word?
}

class Word: ParsableModel {
    var a:[String]?
    var ah:[String]?
    var air:[String]?
    var ar:[String]?
    var ay:[String]?
    var ee:[String]?
    var eer:[String]?
    var eh:[String]?
    var er:[String]?
    var i:[String]?
    var ie:[String]?
    var o:[String]?
    var oh:[String]?
    var or:[String]?
    var oy:[String]?
    var uh:[String]?
    var ure:[String]?
}
