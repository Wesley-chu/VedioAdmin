//
//  ViewController.swift
//  vedioAdmin
//
//  Created by 朱偉綸 on 2021/5/23.
//

import UIKit

class SearchListViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    

    let apiKey = "AIzaSyCNCNNLst8FG-ooCXYpAhrB8LPrslzH0Yc"
    var arrData = [Dictionary<String,String>]()
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var vedioTextField: UITextField!
    
    var text = "74hZJZVwVXo"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vedioTextField.text = text
        searchTableView.dataSource = self
        searchTableView.delegate = self
        
    }
    
    @IBAction func ClickVedioID(_ sender: UIButton) {
        if (vedioTextField.text != nil){
            IDSearch(text: vedioTextField.text!)
        }
    }
    
    
    @IBAction func ClickKeyWord(_ sender: UIButton) {
        if (vedioTextField.text != nil){
            keyWordSearch(text: vedioTextField.text!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // *******************************tableview 処理***********************
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard let title = cell.contentView.subviews[0] as? UILabel else { return cell }
        guard let channelTitle = cell.contentView.subviews[1] as? UILabel else { return cell }
        guard let imageView = cell.contentView.subviews[2] as? UIImageView else { return cell }
        guard let time = cell.contentView.subviews[3] as? UILabel else { return cell }
        
        //讓網路圖片下載時不會卡卡（異步處理）
        DispatchQueue.global().async {
            let data = NSData.init(contentsOf: NSURL.init(string: self.arrData[indexPath.row]["imageURL"]!)! as URL)
            DispatchQueue.main.async {
                let image = UIImage.init(data: data! as Data)
                imageView.image = image
            }
        }
        
        title.text = ChangeFormClass.shared.changeCode(text: arrData[indexPath.row]["title"]!)
        channelTitle.text = ChangeFormClass.shared.changeCode(text: arrData[indexPath.row]["channelTitle"]!)
        time.text = arrData[indexPath.row]["time"]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "searchToModify", sender: arrData[indexPath.row])
    }
    // *******************************tableview 処理***********************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "searchToModify"{
            if let modifyViewController = segue.destination as? ModifyViewController{
                modifyViewController.dicData = sender as! Dictionary<String,String>
            }
        }
    }
    
    
    func IDSearch(text:String){
        let text = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if arrData.count != 0{ arrData.removeAll() }
        
        let str = "https://www.googleapis.com/youtube/v3/videos?id=\(text)&part=contentDetails,snippet&key=\(apiKey)&part=snippet"
        guard let url = URL(string: str) else {return}
        var request2 = URLRequest(url: url)
        request2.httpMethod = "GET"
        var dicData = [String:String]()
        let session2 = URLSession(configuration: .default)
        let task2 = session2.dataTask(with: request2, completionHandler: { (data, response, error) in
            if error != nil{
                debugPrint(error!.localizedDescription)
                print("bad")
                return
            }
            do{
                guard let DLdata = data else {return}
                let json2 = try JSONSerialization.jsonObject(with: DLdata, options: []) as! Dictionary<String, AnyObject>
                let arrJson = json2["items"] as! Array<Dictionary<NSObject, AnyObject>>
                for check2 in arrJson{
                    dicData["videoId"] = (check2 as! Dictionary<String, AnyObject>)["id"] as? String
                    dicData["channelTitle"] = ((check2 as! Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String,AnyObject>)["channelTitle"] as? String
                    dicData["imageURL"] = ((((check2 as! Dictionary<String,AnyObject>)["snippet"] as! Dictionary<String,AnyObject>)["thumbnails"] as! Dictionary<String,AnyObject>)["default"] as! Dictionary<String,AnyObject>)["url"] as? String
                    dicData["title"] = (((check2 as! Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String,AnyObject>)["localized"] as! Dictionary<String,AnyObject>)["title"] as? String
                    var time = ((check2 as! Dictionary<String, AnyObject>)["contentDetails"] as! Dictionary<String, AnyObject>)["duration"] as? String
                    time!.removeFirst()
                    time!.removeFirst()
                    dicData["time"] = ChangeFormClass.shared.changeTimeForm(time: time!)
                }
                //arr.append(dicData)
                self.arrData.append(dicData)
                print(self.arrData,"chu1")
                DispatchQueue.main.async {
                    self.searchTableView.reloadData()
                }
            }catch{
                debugPrint(error.localizedDescription)
                print("bad3")
            }
        })
        task2.resume()
    }
    
    
    func keyWordSearch(text:String){
        
        let text = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        if arrData.count != 0{ arrData.removeAll() }
        let str2 = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(text)&type=video&key=\(apiKey)&maxResults=50&videoCategoryId=10"
        
        
        var arrView =  Array<Dictionary<NSObject, AnyObject>>()
        guard let url = URL(string: str2) else {return}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            if error != nil{
                debugPrint(error!.localizedDescription)
                print("bad")
                return
            }
            do{
                guard let DLdata = data else {return}
                let json = try JSONSerialization.jsonObject(with: DLdata, options: []) as! Dictionary<String, AnyObject>
                arrView = json["items"] as! Array<Dictionary<NSObject, AnyObject>>
                var dicData = [String:String]()
                for check in arrView{
                    let videoId = ((check as! Dictionary<String, AnyObject>)["id"] as! Dictionary<String,AnyObject>)["videoId"] as? String
                    let str = "https://www.googleapis.com/youtube/v3/videos?id=\(videoId!)&part=contentDetails,snippet&key=\(self.apiKey)&part=snippet"
                    guard let url = URL(string: str) else {return}
                    var request2 = URLRequest(url: url)
                    request2.httpMethod = "GET"
                    let session2 = URLSession(configuration: .default)
                    let task2 = session2.dataTask(with: request2, completionHandler: { (data, response, error) in
                        if error != nil{
                            debugPrint(error!.localizedDescription)
                            print("bad")
                            return
                        }
                        do{
                            guard let DLdata = data else {return}
                            let json2 = try JSONSerialization.jsonObject(with: DLdata, options: []) as! Dictionary<String, AnyObject>
                            let arrJson = json2["items"] as! Array<Dictionary<NSObject, AnyObject>>
                            for check2 in arrJson{
                                dicData["videoId"] = (check2 as! Dictionary<String, AnyObject>)["id"] as? String
                                dicData["channelTitle"] = ((check2 as! Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String,AnyObject>)["channelTitle"] as? String
                                dicData["imageURL"] = ((((check2 as! Dictionary<String,AnyObject>)["snippet"] as! Dictionary<String,AnyObject>)["thumbnails"] as! Dictionary<String,AnyObject>)["default"] as! Dictionary<String,AnyObject>)["url"] as? String
                                dicData["title"] = (((check2 as! Dictionary<String, AnyObject>)["snippet"] as! Dictionary<String,AnyObject>)["localized"] as! Dictionary<String,AnyObject>)["title"] as? String
                                var time = ((check2 as! Dictionary<String, AnyObject>)["contentDetails"] as! Dictionary<String, AnyObject>)["duration"] as? String
                                time!.removeFirst()
                                time!.removeFirst()
                                dicData["time"] = ChangeFormClass.shared.changeTimeForm(time: time!)
                            }
                            //arr.append(dicData)
                            self.arrData.append(dicData)
                            print(self.arrData,"chu2")
                            DispatchQueue.main.async {
                                self.searchTableView.reloadData()
                            }
                        }catch{
                            debugPrint(error.localizedDescription)
                            print("bad3")
                        }
                    })
                    task2.resume()
                }
            }catch{
                debugPrint(error.localizedDescription)
                print("bad2")
            }
        }
        task.resume()
    }
    
    
    
    
    


}

