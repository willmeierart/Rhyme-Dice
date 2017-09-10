//
//  RecordingsController.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/7/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import UIKit
import AVFoundation


var audioPlayer2 = AVAudioPlayer()
var recordings:[String] = []
var thisRecording = 0

class RecordingsController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var recordingsTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "recording")
        cell.textLabel?.text = recordings[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        do{
            let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let directoryContents = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys:nil, options:[])
            let m4aFiles = directoryContents.filter{ $0.pathExtension == "m4a" }
            let recordingPath = m4aFiles[indexPath.row]

            try audioPlayer2 = AVAudioPlayer(contentsOf: recordingPath)
            audioPlayer2.play()
            thisRecording = indexPath.row
        }catch{
            print("error")
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        do{
//            var recordingPath: URL
//            recordingPath = getRecordingFile(row: indexPath.row)
            
            let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let directoryContents = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys:nil, options:[])
            let m4aFiles = directoryContents.filter{ $0.pathExtension == "m4a" }
            let recordingPath = m4aFiles[indexPath.row]
            
            if editingStyle == .delete{
                try FileManager.default.removeItem(at: recordingPath)
                getRecordings()
            }
        }catch{
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getRecordings()
    }
    
//    func getRecordingFile(row:Int)->URL{
//        do{
//            let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let directoryContents = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys:nil, options:[])
//            let m4aFiles = directoryContents.filter{ $0.pathExtension == "m4a" }
//            return m4aFiles[row]
//        }catch{}
//    }
    
    
    func getRecordings(){
        let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
            do{
                let recordingPath = try FileManager.default.contentsOfDirectory(at:folderURL, includingPropertiesForKeys:nil, options: .skipsHiddenFiles)
                for recording in recordingPath{
                    var myRecording = recording.absoluteString
                    if myRecording.contains(".m4a"){
                        let findString = myRecording.components(separatedBy: "/")
                        myRecording = findString[findString.count-1]
                        myRecording = myRecording.replacingOccurrences(of: "%20", with: " ")
                        myRecording = myRecording.replacingOccurrences(of: ".m4a", with: "")
                        if !recordings.contains(myRecording){
                            recordings.append(myRecording)
                        }
                    }
                }
                recordingsTable.reloadData()
            }
            catch{
                
            }

    }
}
