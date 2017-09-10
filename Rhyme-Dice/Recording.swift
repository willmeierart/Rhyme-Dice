//
//  Recording.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/9/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import Foundation

class Recording {
    
    let title : String
    let length : Int
    let recorded_at : Date
    let recorded_by: String
    let filepath : URL
    let APIsrc : String
    let tagged : [String]
    
    init(rec_title : String, rec_length : Int, rec_date : Date, rec_user: String, rec_path : URL, rec_src : String, rec_friends : [String]){
        title = rec_title
        length = rec_length
        recorded_at = rec_date
        recorded_by = rec_user
        filepath = rec_path
        APIsrc = rec_src
        tagged = rec_friends
    }
    
}
