//
//  RecordingsController.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/7/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import UIKit

class RecordingsController: UIViewController{
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

//
//func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    return songs.count
//}
//
//func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = UITableViewCell(style: .default, reuseIdentifier: "player")
//    cell.textLabel?.text = songs[indexPath.row]
//    return cell
//}
//
//func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    do{
//        let audioPath = Bundle.main.path(forResource: songs[indexPath.row], ofType: ".mp3")
//        try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
//        audioPlayer.play()
//        thisSong = indexPath.row
//        audioStuffed = true
//    }catch{
//        print("error")
//    }
//}
//
//
//func getSongs(){
//    let folderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
//    
//    do{
//        let songPath = try FileManager.default.contentsOfDirectory(at:folderURL, includingPropertiesForKeys:nil, options: .skipsHiddenFiles)
//        
//        for song in songPath{
//            var mySong = song.absoluteString
//            if mySong.contains(".mp3"){
//                let findString = mySong.components(separatedBy: "/")
//                mySong = findString[findString.count-1]
//                mySong = mySong.replacingOccurrences(of: "%20", with: " ")
//                mySong = mySong.replacingOccurrences(of: ".mp3", with: "")
//                songs.append(mySong)
//                print(songs)
//            }
//        }
//        playerTable.reloadData()
//    }
//    catch{
//        
//    }
//}
