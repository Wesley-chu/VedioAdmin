//
//  modifyVedioViewController.swift
//  vedioAdmin
//
//  Created by 朱偉綸 on 2021/5/23.
//

import UIKit
import CloudKit

class ModifyListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var songTableView: UITableView!
    
    var arrData = [Dictionary<String,String>]()
    var date:String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentDay = Calendar.current.component(.day, from: Date())
        date = "\(currentYear)" + "\(ChangeFormClass.shared.dayToDay(day: currentMonth))" + "\(ChangeFormClass.shared.dayToDay(day: currentDay))"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        songTableView.delegate = self
        songTableView.dataSource = self
        
        query()
        updateTable()
    }
    
    var refreshControl = UIRefreshControl()
    func updateTable(){
        refreshControl.addTarget(self, action: #selector(query), for: UIControl.Event.valueChanged)
        songTableView.refreshControl = refreshControl
    }
    
    
    @objc func query(){
        let database = CKContainer.default().publicCloudDatabase
        let query = CKQuery(recordType: "modifyVideoInfo", predicate: NSPredicate(value: true))
        let operation = CKQueryOperation(query: query)
        var arr = [Dictionary<String,String>]()
        operation.queuePriority = .veryHigh; operation.resultsLimit = 300
        operation.recordFetchedBlock = {(records:CKRecord?) in
            guard let record = records else { return }
            var dic = [String:String]()
            dic["videoId"] = record["videoId"] as! String
            dic["title"] = record["title"] as! String
            dic["subtitle"] = record["subtitle"] as! String
            dic["imageURL"] = record["imageURL"] as! String
            dic["time"] = record["time"] as! String
            dic["level"] = record["level"] as! String
            dic["genre"] = record["genre"] as! String
            dic["keyinDate"] = record["keyinDate"] as! String
            print(dic)
            arr.append(dic)
            self.arrData = arr
            DispatchQueue.main.async {
                self.songTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
            
        }
        operation.queryCompletionBlock = {(cursor,error) in
            arr.removeAll()
        }; database.add(operation)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell3", for: indexPath)
        guard let imageView = cell.contentView.subviews[2] as? UIImageView else { return cell }
        guard let title = cell.contentView.subviews[0] as? UILabel else { return cell }
        guard let channelTitle = cell.contentView.subviews[3] as? UILabel else { return cell }
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "modifyListToModify", sender: arrData[indexPath.row])
    }
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let dicData = arrData[indexPath.row]
//        let modifyTitle = UITableViewRowAction(style: .normal, title: "名前") { (action, index) in
//            self.warnAlert(message: "タイトルをご入力下さい", num: indexPath.row)
//        }
//
//        let toRunLyric = UITableViewRowAction(style: .normal, title: "確認") { (action, index) in
//            var arr = [String]()
//            arr.append(self.arrData[indexPath.row]["videoId"]!)
//            arr.append(self.arrData[indexPath.row]["lyric"]!)
//            self.performSegue(withIdentifier: "toRunLyricSegue", sender: arr)
//        }
//
//        let save = UITableViewRowAction(style: .normal, title: "保存") { (action, index) in
//            Cloud.shared.insert(videoId: dicData["videoId"]!, title: dicData["title"]!, time: dicData["time"]!, imageURL: dicData["imageURL"]!, subtitle: dicData["subtitle"]!, level: dicData["level"]!, genre: dicData["genre"]!, keyinDate: self.date)
//        }
//        return [save,toRunLyric,modifyTitle]
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let dicData = arrData[indexPath.row]
        let modifyTitle = UIContextualAction(style: .normal, title: "名前") { (action, view, handler) in
            self.warnAlert(message: "タイトルをご入力下さい", num: indexPath.row)
            handler(true)
        }
        let toRunLyric = UIContextualAction(style: .normal, title: "確認") { (action, view, handler) in
            var arr = [String]()
            arr.append(self.arrData[indexPath.row]["videoId"]!)
            arr.append(self.arrData[indexPath.row]["subtitle"]!)
            self.performSegue(withIdentifier: "modifyToPlayer", sender: arr)
            handler(true)
        }
        let save = UIContextualAction(style: .normal, title: "保存") { (action, view, handler) in
            Cloud.shared.insert(videoId: dicData["videoId"]!, title: dicData["title"]!, time: dicData["time"]!, imageURL: dicData["imageURL"]!, subtitle: dicData["subtitle"]!, level: dicData["level"]!, genre: dicData["genre"]!, keyinDate: self.date, recordType: .videosInfo)
            handler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [modifyTitle, toRunLyric, save])
            configuration.performsFirstActionWithFullSwipe = true //falseにすると、フルスワイプしてもアクションが実行されなくなる
        return configuration
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modifyListToModify"{
            guard let toPlayTubeView = segue.destination as? ModifyViewController else{ return }
            toPlayTubeView.dicData = sender as! [String : String]
            toPlayTubeView.ifSongExist = true
            
        }else if segue.identifier == "modifyToPlayer"{
            guard let toViewController = segue.destination as? VideoViewController else{ return }
            toViewController.arrId_Lyric = sender as! [String]
        }
    }
    
    
    
    func warnAlert(message:String,num:Int){
        let Alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertController.Style.alert)
        
        Alert.addTextField { (UITextField) in UITextField.placeholder = "Title 中国語" }
        Alert.addTextField { (UITextField) in UITextField.placeholder = "Title 日本語" }
        
        if (arrData[num]["title"]?.components(separatedBy: "_").count)! > 1{
            Alert.textFields?[0].text = arrData[num]["title"]?.components(separatedBy: "_")[0]
            Alert.textFields?[1].text = arrData[num]["title"]?.components(separatedBy: "_")[1]
        }else{
            Alert.textFields?[0].text = arrData[num]["title"]
            Alert.textFields?[1].text = ""
        }
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (UIAlertAction) in
            let Chinese = Alert.textFields?[0].text
            let Japanese = Alert.textFields?[1].text
            let Title = Chinese! + "_" + Japanese!
            Cloud.shared.update(videoId: self.arrData[num]["videoId"]!, title: Title, time: self.arrData[num]["time"]!, imageURL: self.arrData[num]["imageURL"]!, subtitle: self.arrData[num]["subtitle"]!, level: self.arrData[num]["level"]!, genre: self.arrData[num]["genre"]!, keyinDate: "")
            self.arrData[num]["title"] = Title
            self.songTableView.reloadData()
            }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        
        Alert.addAction(okAction)
        Alert.addAction(cancel)
        present(Alert, animated: true, completion: nil)
    }
    
    
    


}
