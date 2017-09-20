//
//  RecordingsController.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/7/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import UIKit
import AVFoundation

var thisRecording = 0

class RecordingsController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
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

            Player.loadNewSource(source:recordingPath)
            
            thisRecording = indexPath.row
            audioStuffed = true
            
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Main")
            let mainPlayBtn = vc.view.viewWithTag(1) as? UIButton
            
            DispatchQueue.main.asyncAfter(deadline: .now()){
                Player.Play(button:self.playButton)
                mainPlayBtn?.setImage(UIImage(named:"playerPause"), for: .normal)
                DispatchQueue.main.asyncAfter(deadline: .now()){
                    self.playButton.setImage(UIImage(named:"playerPause"), for: .normal)
                }
            }
        }catch{
            print(error)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        UIButton.appearance().setTitleColor(UIColor.black, for: .normal)

        var recordingPath = recordings[indexPath.row]
        
        let Edit = UITableViewRowAction(style: .normal, title: "edit") { (rowAction, indexPath) in
            print("edited")
            self.renameRecording(path:recordingPath, title:recordingTitles[indexPath.row], row:indexPath.row, indexPath: indexPath)
        }
        Edit.backgroundColor = .yellow
        
        let Delete = UITableViewRowAction(style: .normal, title: "delete") { (rowAction, indexPath) in
            recordings.remove(at:indexPath.row)
            recordingTitles.remove(at:indexPath.row)
            self.recordingsTable.deleteRows(at: [indexPath], with: .automatic)
            print("recordingPath", recordingPath)
            try! FileManager.default.removeItem(at: recordingPath)
        }
        Delete.backgroundColor = .red
        return [Delete, Edit]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        RecordingsDataManager.getStoredRecordings()
//        print(recordingTitles)
        topBar.layer.shadowColor = UIColor.black.cgColor
        topBar.layer.shadowOpacity = 0.5
        topBar.layer.shadowOffset = CGSize(width:0, height:4.0)
        topBar.layer.shadowRadius = 4
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        RecordingsDataManager.getStoredRecordings()
    }
    
    func renameRecording(path:URL, title:String, row:Int, indexPath:IndexPath){
        var alertController:UIAlertController?
        alertController = UIAlertController(title: "Rename Recording",
                                            message: nil,
                                            preferredStyle: .alert)
        alertController!.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = title
        })
        let action = UIAlertAction(title: "Save",
                                   style:UIAlertActionStyle.default,
                                   handler: {[weak self]
                                    (paramAction:UIAlertAction) in
                                    if let textFields = alertController?.textFields{
                                        let theTextFields = textFields as [UITextField]
                                        let enteredText = theTextFields[0].text
                                        
                                        let basePath = path.deletingLastPathComponent()
//                                        var Path = path
                                        
                                        let newName = enteredText!.replacingOccurrences(of: " ", with: "%20")
                                        print(newName)
                                        
                                        let newFilePath:URL = URL(string:"\(basePath)\(newName).m4a")!
                                        
//                                        print(newName)
                                        
                                        
                                        do {
                                            self?.recordingsTable.deleteRows(at: [indexPath], with: .automatic)
                                            recordings.remove(at:row)
                                            recordingTitles.remove(at:row)
                                            recordings.append(newFilePath)
                                            recordingTitles.append(newName)
                                            
                                            
                                            print(newFilePath)
                                            print(path)
                                            
                                            try! FileManager.default.moveItem(at: path, to: newFilePath)
                                            
//                                            path = newFilePath
                                            DispatchQueue.main.asyncAfter(deadline: .now()){
                                                print("newFilePath", newFilePath)
                                                RecordingsDataManager.uploadToAWS(file:newFilePath)
                                                DispatchQueue.main.asyncAfter(deadline: .now()){
                                                    RecordingsDataManager.getStoredRecordings()
                                                    DispatchQueue.main.asyncAfter(deadline: .now()){
                                                        self?.getRecordings()
                                                    }
                                                }
                                            }
                                           
                                        } catch {print(error)}
                                    }
                                })
        
        alertController?.addAction(action)
        self.present(alertController!, animated:true, completion:nil)
        
    }
    
    func getRecordings(){
        RecordingsDataManager.getStoredRecordings()
        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.recordingsTable.reloadData()
        }
        
        
        
    }
}
