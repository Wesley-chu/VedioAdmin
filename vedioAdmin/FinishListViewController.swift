//
//  FinishListViewController.swift
//  vedioAdmin
//
//  Created by 朱偉綸 on 2021/5/23.
//

import UIKit
import CloudKit

class FinishListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var songTableView: UITableView!
    var arrData = [Dictionary<String,String>]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        query()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "finishToPlayer"{
            if let toVideoViewController = segue.destination as? VideoViewController{
                toVideoViewController.arrId_Lyric = sender as! Array
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath)
        guard let imageView = cell.contentView.subviews[0] as? UIImageView else { return cell }
        guard let title = cell.contentView.subviews[1] as? UILabel else { return cell }
        guard let channelTitle = cell.contentView.subviews[2] as? UILabel else { return cell }
        
        
        //讓網路圖片下載時不會卡卡（異步處理）
        DispatchQueue.global().async {
            let data = NSData.init(contentsOf: NSURL.init(string: self.arrData[indexPath.row]["imageURL"]!)! as URL)
            DispatchQueue.main.async {
                let image = UIImage.init(data: data! as Data)
                imageView.image = image
            }
        }
        
        if arrData[indexPath.row]["title"]!.components(separatedBy: "_").count == 1{
            title.text = ChangeFormClass.shared.changeCode(text: arrData[indexPath.row]["title"]!)
        }else{
            let Chinese = arrData[indexPath.row]["title"]!.components(separatedBy: "_")[0]
            let Japanese = arrData[indexPath.row]["title"]!.components(separatedBy: "_")[1]
            title.text = Chinese + "\n" + Japanese
        }
        channelTitle.text = ChangeFormClass.shared.changeCode(text: arrData[indexPath.row]["time"]!)
        return cell
    }
    
    var arrPass = [String]()
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let key = arrData[indexPath.row]["videoId"] else { return }
        guard let lyric = arrData[indexPath.row]["lyric"] else { return }
        
        arrPass.append(key)
        arrPass.append(lyric)
        performSegue(withIdentifier: "toPlaySegue", sender: arrPass)
        
        arrPass.removeAll()
    }
    
    func query(){
        let database = CKContainer.default().publicCloudDatabase
        var query = CKQuery(recordType: "videosInfo", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        operation.queuePriority = .veryHigh; operation.resultsLimit = 300
        operation.recordFetchedBlock = {(records:CKRecord?) in
            guard let record = records else { return }
            var dic = [String:String]()
            dic["videoId"] = record["videoId"] as! String
            dic["title"] = record["title"] as! String
            dic["subtitle"] = record["subtitle"] as! String
            dic["imageURL"] = record["imageURL"] as! String
            dic["time"] = record["time"] as! String
            dic["keyinDate"] = record["keyinDate"] as! String
            
            self.arrData.append(dic)
            DispatchQueue.main.async {
                self.songTableView.reloadData()
            }
        }; database.add(operation)
    }
    
    
    
    
    


}
