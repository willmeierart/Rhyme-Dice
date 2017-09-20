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
    
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var playButton: UIButton!
    @IBAction func play(_ sender: Any) {
        Player.Play(button: playButton)
    }
    @IBAction func prev(_ sender: Any) {
        Player.Prev()
    }
    @IBAction func next(_ sender: Any) {
        Player.Next()
    }
    
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
            Player.loadNewSource(source:NSURL(fileURLWithPath: audioPath!) as URL)
            
            thisSong = indexPath.row
            audioStuffed = true
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Main")
            let mainPlayBtn = vc.view.viewWithTag(1) as? UIButton
            
            DispatchQueue.main.asyncAfter(deadline: .now()){
                Player.Play(button:self.playButton)
                mainPlayBtn?.setImage(UIImage(named:"playerPause"), for: .normal)
                DispatchQueue.main.asyncAfter(deadline: .now()){
                    
                    self.playButton.setImage(UIImage(named:"playerPause"), for: .normal)
                    self.performSegue(withIdentifier: "Beats2Home", sender: self)
                }
            }
        }catch{
            print("error")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSongs()
        topBar.layer.shadowColor = UIColor.black.cgColor
        topBar.layer.shadowOpacity = 0.5
        topBar.layer.shadowOffset = CGSize(width:0, height:4.0)
        topBar.layer.shadowRadius = 4
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
