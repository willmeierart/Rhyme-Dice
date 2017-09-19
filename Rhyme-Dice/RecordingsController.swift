//
//  RecordingsController.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/7/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import UIKit
import AVFoundation

//var audioPlayer2 = AVAudioPlayer()
//var recordings:[URL] = []
//var recordingTitles:[String] = []
//var thisRecording = 0

class RecordingsController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var recordingsTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "recording")
        cell.textLabel?.text = recordingTitles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do{
            let recordingPath = recordings[indexPath.row]

//            try audioPlayer = AVAudioPlayer(contentsOf: recordingPath)
            
            Player.loadNewSource(source:recordingPath)
            
            Player.Play()
//            audioPlayer.play()
            thisRecording = indexPath.row
        }catch{
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        do{
            let recordingPath = recordings[indexPath.row]
            
            if editingStyle == .delete{
                recordings.remove(at:indexPath.row)
                recordingTitles.remove(at:indexPath.row)
                recordingsTable.deleteRows(at: [indexPath], with: .automatic)
                try FileManager.default.removeItem(at: recordingPath)
            }
        }catch{
            print(error)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getRecordings()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRecordings()
    }
    
    func getRecordings(){
        let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        recordings = []
        recordingTitles = []
            do{
                let recordingPath = try FileManager.default.contentsOfDirectory(at:folderURL, includingPropertiesForKeys:nil, options: .skipsHiddenFiles)
                for recording in recordingPath{
                    var myRecording = recording.absoluteString
                    if myRecording.contains(".m4a"){
                        recordings.append(recording)
                        let asset = AVURLAsset(url:recording)
                        let recDuration = asset.duration
                        let recDurationSecs = CMTimeGetSeconds(recDuration)
                        var formatDur = String(format:"%.2f", recDurationSecs)
                        formatDur = formatDur.replacingOccurrences(of: ".", with: ":")
                        let findString = myRecording.components(separatedBy: "/")
                        myRecording = findString[findString.count-1]
                        myRecording = myRecording.replacingOccurrences(of: "%20", with: " ")
                        myRecording = myRecording.replacingOccurrences(of: ".m4a", with: "")
                        myRecording = "\(myRecording) - \(formatDur)"
                        if !recordingTitles.contains(myRecording){
                            recordingTitles.append(myRecording)
                        }
                    }
                }
                recordingsTable.reloadData()
            }
            catch{
                
            }
    }
}
