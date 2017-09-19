//
//  PlayerController.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/6/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import UIKit
import AVFoundation



class PlayerController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var playerTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "player")
        cell.textLabel?.text = songs[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do{
           let audioPath = Bundle.main.path(forResource: songs[indexPath.row], ofType: ".mp3")
//            try audioPlayer = AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: audioPath!) as URL)
//            audioPlayer.url =  NSURL(fileURLWithPath: audioPath!)
            Player.loadNewSource(source:NSURL(fileURLWithPath: audioPath!) as URL)
//            audioPlayer.play()
            Player.Play()
            thisSong = indexPath.row
            audioStuffed = true
            DispatchQueue.main.asyncAfter(deadline: .now()){
                self.performSegue(withIdentifier: "Beats2Home", sender: self)
            }
        }catch{
            print("error")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSongs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func getSongs(){
        let folderURL = URL(fileURLWithPath: Bundle.main.resourcePath!)
        do{
            let songPath = try FileManager.default.contentsOfDirectory(at:folderURL, includingPropertiesForKeys:nil, options: .skipsHiddenFiles)

            for song in songPath{
                var mySong = song.absoluteString
                if mySong.contains(".mp3"){
                    let findString = mySong.components(separatedBy: "/")
                    mySong = findString[findString.count-1]
                    mySong = mySong.replacingOccurrences(of: "%20", with: " ")
                    mySong = mySong.replacingOccurrences(of: ".mp3", with: "")
                    songs.append(mySong)
                }
            }
            playerTable.reloadData()
        }
        catch{}
    }
}
