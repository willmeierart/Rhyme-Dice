//
//  AWSManager.swift
//  Rhyme-Dice
//
//  Created by Will Meier on 9/18/17.
//  Copyright © 2017 Will Meier. All rights reserved.
//

import Foundation
import AVFoundation
import SwiftyJSON
import Alamofire
import AWSCore
import AWSCognito
import AWSS3

var recordings:[URL] = []
var recordingTitles:[String] = []

var myRecordings:[String] = []
var myRecordingTitles:[String] = []
var taggedRecordings:[String] = []
var taggedRecordingTitles:[String] = []
let baseAPIurl:String = "https://rhymedice.herokuapp.com/recordings/"

class RecordingsDataManager {

    static func updateAllDataFromServer(){
        self.getStoredRecordings()
        let data = UserDefaults.standard.object(forKey:"AppData") as? [String:Any]
        self.fetchSet(data:data!, set:"my", completion:{response in
            parseData(data:response, set:"my")
            self.fetchSet(data:data!, set:"tagged", completion:{response in
                parseData(data:response, set:"tagged")
//                print(myRecordings)
//                print(myRecordingTitles)
//                print(taggedRecordings)
//                print(taggedRecordingTitles)
                self.compareAndDownloadNew()
            })
            
        })
    }
    
    static func compareAndDownloadNew(){
        let titles = Array([myRecordingTitles, taggedRecordingTitles].joined())
        let recs = Array([myRecordings, taggedRecordings].joined())
        for title in titles {
            if !recordingTitles.contains(title){
                self.downloadRecordingFromAWS(rec:recordings[titles.index(of:title)!])
                recordingTitles.append(title)
            }

//            recordingTitles.append(title)
        }
//        for recording in recs {
//            if !recordings.contains(URL(string: recording)!){
//                self.downloadRecordingFromAWS(rec:recording)
////                 recordings.append(URL(string: recording)!)
//            }
////
//        }
//        print(recordingTitles)
//        print(recordings)
    }
    
    static func downloadRecordingFromAWS(rec:String) {
        if let audioUrl = URL(string: rec) {
//            print(audioUrl)
//            let documentsUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//            let destination = documentsUrl.appendingPathComponent(audioUrl.lastPathComponent)
////            print(destination)
//            if FileManager().fileExists(atPath: destination.path) {
//                print("The file already exists at path")
//            } else {
//                print("ok")
//                URLSession.shared.downloadTask(with: audioUrl, completionHandler: { (location, response, error) in
//                    guard
//                        let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
//                        let mimeType = response?.mimeType, mimeType.hasPrefix("audio"),
//                        let location = location, error == nil
//                        else {
//                            print("ejected")
//                            return }
//                    do {
//                        try FileManager.default.moveItem(at: location, to: destination)
//                        print("file saved")
//                    } catch {
//                        print(error)
//                    }
//                }).resume()
//            }
//            let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//            let destination = try FileManager.default.contentsOfDirectory(at:folderURL, includingPropertiesForKeys:nil, options: .skipsHiddenFiles)
            let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            Alamofire.download(audioUrl, to:destination).responseData { response in
                if let data = response.result.value {
//                    print(data)
                }
            }
        }
    }
    
    static func parseData(data:JSON, set:String){
        let dataSet = data[0]["\(set)_recordings"]
        
        for recording in dataSet.arrayValue {
            if set == "my" {
                myRecordings.append(recording["url"].stringValue)
                myRecordingTitles.append(recording["title"].stringValue)
            }
            if set == "tagged" {
                taggedRecordings.append(recording["url"].stringValue)
                taggedRecordingTitles.append(recording["title"].stringValue)
            }
        }
    }
    
    static func fetchSet(data:[String:Any], set:String, completion: @escaping (_ success: JSON) -> Void){
//        print(data)
        let myID = data["id"] as? String
        let fetchURL = "\(baseAPIurl)\(set)/\(myID!)"
        Alamofire.request(fetchURL, method: .get, parameters:["id":String(describing: data["id"])]).responseJSON{ response in
            if response.result.isSuccess {
                let response:JSON = JSON(response.result.value!)
                completion(response)
            } else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    static func getStoredRecordings(){
        let folderURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do{
            let recordingPath = try FileManager.default.contentsOfDirectory(at:folderURL, includingPropertiesForKeys:nil, options: .skipsHiddenFiles)
            for recording in recordingPath{
//                print(recording)
                var myRecording = recording.absoluteString
                if myRecording.contains(".m4a"){
                    print(recording)
                    recordings.append(recording)
                    let asset = AVURLAsset(url:recording)
                    let recDuration = asset.duration
                    let recDurationSecs = CMTimeGetSeconds(recDuration)
                    var formatDur = String(format:"%.2f", recDurationSecs)
                    formatDur = formatDur.replacingOccurrences(of: ".", with: ":")
//                    print(recording)
                    
                    myRecording = recording.lastPathComponent
                    myRecording = formatRecordingTitle(recording: myRecording)
//                    print(myRecording)

                    
                    
//                    myRecording = "\(myRecording) - \(formatDur)"
                    if !recordingTitles.contains(myRecording){
                        recordingTitles.append(myRecording)
                    }
                }
            }
        }
        catch{}
    }
    static func formatRecordingTitle(recording:String) -> String{
        var formatted = recording.replacingOccurrences(of: "%20", with: " ")
        formatted = recording.replacingOccurrences(of: ".m4a", with: "")
        return formatted
    }
    
    static func uploadToAWS(file:URL){
        //        let file = audioFilePath!
        let uniqueFileName = NSUUID().uuidString + "-" + file.lastPathComponent
        let bucket = "rhyme-dice-audio-va"
        
        let transferManager = AWSS3TransferManager.default()
        let uploadRequest = AWSS3TransferManagerUploadRequest()!
        uploadRequest.bucket = bucket
        uploadRequest.key = uniqueFileName
        uploadRequest.body = file
        uploadRequest.acl = AWSS3ObjectCannedACL.publicReadWrite
        transferManager.upload(uploadRequest).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
            
            if let error = task.error { print("upload failed with error: \(error)") }
            if task.result != nil {
                //                let s3URL = NSURL(string:"https://s3.amazonaws.com/\(bucket)/\(uniqueFileName)")
                //                uploadRecordingData(recURL:s3URL)
            } else { print("unexpected empty result") }
            return nil
        })
    }
    
}
