//
//  DatabaseManager.swift
//  vedioAdmin
//
//  Created by 朱偉綸 on 2021/5/23.
//

import Foundation
import CloudKit

enum recordType: String {
    case modifyVideoInfo = "modifyVideoInfo"
    case videosInfo = "videosInfo"
}


class Cloud {
    static let shared = Cloud()
    let database = CKContainer.default().publicCloudDatabase
    
    func insert(videoId:String,title:String,time:String,imageURL:String,subtitle:String,level:String,genre:String,keyinDate:String,recordType:recordType){
        var save:CKRecord
        save = CKRecord(recordType: recordType.rawValue)
        
        save.setValue(videoId, forKey: "videoId")
        save.setValue(title, forKey: "title")
        save.setValue(time, forKey: "time")
        save.setValue(imageURL, forKey: "imageURL")
        save.setValue(subtitle, forKey: "subtitle")
        save.setValue(level, forKey: "level")
        save.setValue(genre, forKey: "genre")
        save.setValue(keyinDate, forKey: "keyinDate")
        self.database.save(save) { (_, error) in
            if error != nil{
                print(error,"chu11")
            }else{
                print("saveDone1")
            }
        }
        
    }
    
    func update(videoId:String,title:String,time:String,imageURL:String,subtitle:String,level:String,genre:String,keyinDate:String){
        let query = CKQuery(recordType: "modifyVideoInfo", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        operation.queuePriority = .veryHigh; operation.resultsLimit = 300
        operation.recordFetchedBlock = {(records:CKRecord?) in
            guard let record = records else { return }
            if record["videoId"] as! String == videoId{
                record["title"] = title as CKRecordValue
                record["time"] = time as CKRecordValue
                record["imageURL"] = imageURL as CKRecordValue
                record["subtitle"] = subtitle as CKRecordValue
                record["level"] = level as CKRecordValue
                record["genre"] = genre as CKRecordValue
                record["keyinDate"] = keyinDate as CKRecordValue
                self.database.save(record, completionHandler: { (_, error) in
                    if error != nil{
                        print(error,"chu12")
                    }else{
                        print("updateDone1")
                    }
                })
            }
        }; database.add(operation)
    }
    
    
    
    
    
    
    
    
}


