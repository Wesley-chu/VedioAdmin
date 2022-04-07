//
//  ModifyViewController.swift
//  vedioAdmin
//
//  Created by 朱偉綸 on 2021/5/25.
//

import UIKit
import WebKit
import AVFoundation
import MediaPlayer
import YoutubePlayer_in_WKWebView

class ModifyViewController: UIViewController,WKYTPlayerViewDelegate,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {
    
    @IBOutlet weak var webView2: WKYTPlayerView!
    @IBOutlet weak var lyricTableView: UITableView!
    
    @IBOutlet weak var beQuik: UIButton!
    @IBOutlet weak var beSlow: UIButton!
    
    @IBOutlet weak var chineseKeyboard: UITextView!
    @IBOutlet weak var japaneseKeyboard: UITextView!
    @IBOutlet weak var numberKeyboard: UITextView!
    @IBOutlet weak var levelKeyboard: UITextView!
    @IBOutlet weak var genreKeyboard: UITextView!
    
    @IBOutlet weak var keyinView: UIView!
    
    var keyinViewPoint:CGFloat = 0.0
    var keyinViewHeight:CGFloat = 0.0
    let playerVars = ["playsinline" : 1]
    var checkIfSave = true
    var checkKeyboard = false
    var dicData = [String:String]()
    var arrLyric = [String]()
    var ifSongExist = false
    
    override func viewWillAppear(_ animated: Bool) {
        print(keyinView.frame.origin.y,"chu2")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(self.lyricTableView.frame.size.height,"chu10")
        print(keyinView.frame.origin.y,"chu3")
    }
    
    override func viewWillLayoutSubviews() {
        print(keyinView.frame.origin.y,"chu5")
    }
    
    override func viewDidLayoutSubviews() {
        let safeArea = self.view.frame.size.height - self.view.safeAreaLayoutGuide.layoutFrame.maxY
        
        if checkKeyboard == false{
            setView()
            keyinViewPoint = keyinView.frame.origin.y
            keyinViewHeight = lyricTableView.frame.size.height
        }else{
            print(safeArea,"chu6")
            print(self.view.frame.size.height,"chu7")
            print(self.view.safeAreaLayoutGuide.layoutFrame.maxY,"chu8")
            UIView.animate(withDuration: 0.25, animations: {
                self.lyricTableView.frame.origin.y = self.webView2.frame.maxY + 5
                self.keyinView.frame.origin.y = self.keyinViewPoint - self.keyboardPoint + safeArea
                self.lyricTableView.frame.size.height = self.keyinViewHeight - self.keyboardPoint + safeArea
            })
        }
        print(keyinView.frame.origin.y,"chu4")
        print(self.lyricTableView.frame.size.height,"chu9")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView2.delegate = self
        lyricTableView.delegate = self
        lyricTableView.dataSource = self
        chineseKeyboard.delegate = self
        japaneseKeyboard.delegate = self
        numberKeyboard.delegate = self
        levelKeyboard.delegate = self
        genreKeyboard.delegate = self
        
        print(keyinView.frame.origin.y,"chu1")
        
        if ifSongExist == true{
            if dicData["subtitle"]!.components(separatedBy: "|").count == 1{
                arrLyric.append(dicData["subtitle"]!)
            }else{
                arrLyric = dicData["subtitle"]!.components(separatedBy: "|")
            }
        }
        levelKeyboard.text = dicData["level"]
        genreKeyboard.text = dicData["genre"]
        play(videoId: dicData["videoId"]!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange(aNotification:)), name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    var checkSpeed:Float = 1
    @IBAction func speed(_ sender: UIButton) {
        if sender == beQuik{
            if checkSpeed != 2{
                checkSpeed += 0.25
                webView2.setPlaybackRate(checkSpeed)
            }
        }else{
            if checkSpeed != 0.25{
                checkSpeed -= 0.25
                webView2.setPlaybackRate(checkSpeed)
            }
        }
    }
    
    
    
    var keyboardPoint = CGFloat()
    @objc func keyboardFrameWillChange(aNotification:Notification){
        let safeArea = self.view.frame.size.height - self.view.safeAreaLayoutGuide.layoutFrame.maxY
        let keyboardSize = aNotification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        keyboardPoint = (keyboardSize?.size.height)!
        if checkKeyboard == true{
            
            UIView.animate(withDuration: 0.25, animations: {
                self.lyricTableView.frame.origin.y = self.webView2.frame.maxY + 5
                self.keyinView.frame.origin.y = self.keyinViewPoint - self.keyboardPoint + safeArea
                self.lyricTableView.frame.size.height = self.keyinViewHeight - self.keyboardPoint + safeArea
            })
        }
        //NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        closeKeyboard()
    }
    
    func play(videoId:String){
        webView2.load(withVideoId: videoId, playerVars: playerVars)
    }
    
    func putLyricInArrAndShow(){
        
        let number = numberKeyboard.text!
        let Chinese = chineseKeyboard.text!
        let Japanese = japaneseKeyboard.text!
        
        let str = number + "_" + Chinese + "_" + Japanese
        arrLyric.append(str)
        
        let insertInfoAtThisIndexPath = IndexPath(row: arrLyric.count - 1, section: 0)
        lyricTableView.insertRows(at: [insertInfoAtThisIndexPath], with: .right)
        lyricTableView.scrollToRow(at: IndexPath(row: arrLyric.count - 1, section: 0), at: .bottom, animated: true)
        numberKeyboard.text = ""; chineseKeyboard.text = ""; japaneseKeyboard.text = ""
        modify_flg = nil
    }
    
    
    func modifyLyricAndShow(){
        let number = numberKeyboard.text!
        let Chinese = chineseKeyboard.text!
        let Japanese = japaneseKeyboard.text!
        let str = number + "_" + Chinese + "_" + Japanese
        arrLyric[modify_flg!] = str
        lyricTableView.reloadData()
        
        numberKeyboard.text = ""; chineseKeyboard.text = ""; japaneseKeyboard.text = ""
        modify_flg = nil
    }
    
    func closeKeyboard(){
        checkKeyboard = false
        self.view.endEditing(true)
    }
    
    func warnAlert(message:String){
        let Alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        Alert.addAction(okAction)
        present(Alert, animated: true, completion: nil)
    }
    
    func warnAlert_YesNo(message:String,handler:@escaping (UIAlertAction) -> Void){
        let Alert = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "YES", style: UIAlertAction.Style.default, handler: handler)
        let noAction = UIAlertAction(title: "NO", style: UIAlertAction.Style.default, handler: nil)
        Alert.addAction(okAction)
        Alert.addAction(noAction)
        present(Alert, animated: true, completion: nil)
    }
    
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            closeKeyboard()
            return false
        }else{
            return true
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        checkKeyboard = true
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if arrLyric.count != 0 && modify_flg == nil{
            lyricTableView.scrollToRow(at: IndexPath(row: arrLyric.count - 1, section: 0), at: .bottom, animated: true)
        }else if modify_flg != nil{
            lyricTableView.scrollToRow(at: IndexPath(row: modify_flg!, section: 0), at: .middle, animated: true)
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if checkKeyboard == false{
            UIView.animate(withDuration: 0.25) {
                self.keyinView.frame.origin.y = self.keyinViewPoint
                self.lyricTableView.frame.size.height = self.keyinViewHeight
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLyric.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath)
        guard let textLabel = cell.contentView.subviews[1] as? UILabel else { return cell }
        guard let textLabel2 = cell.contentView.subviews[0] as? UILabel else { return cell }
        textLabel.text = String(arrLyric[indexPath.row].components(separatedBy: "_")[1]) + "\n" + String(arrLyric[indexPath.row].components(separatedBy: "_")[2])
        textLabel2.text = String(arrLyric[indexPath.row].components(separatedBy: "_")[0])
        
        return cell
    }
    
    var modify_flg:Int?
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        modify_flg = indexPath.row
        let lyric = arrLyric[indexPath.row]
        numberKeyboard.text = lyric.components(separatedBy: "_")[0]
        chineseKeyboard.text = lyric.components(separatedBy: "_")[1]
        japaneseKeyboard.text = lyric.components(separatedBy: "_")[2]
        levelKeyboard.text = dicData["level"]
        genreKeyboard.text = dicData["genre"]
        checkIfSave = false
    }
    
    
    
    @IBAction func enterLyric(_ sender: UIButton) {
        //時間のところに数字しかいれられない
        if Int(numberKeyboard.text) == nil{warnAlert(message: "数字を入力して下さい"); return}
        //空じゃ行けない
        if numberKeyboard.text == "" || (chineseKeyboard.text == "" && japaneseKeyboard.text == ""){ warnAlert(message: "時間または歌詞を入力して下さい"); return}
        
        if modify_flg == nil{
            putLyricInArrAndShow()
        }else{
            modifyLyricAndShow()
        }
        checkIfSave = false
    }
    
    @IBAction func toCheckLyric(_ sender: UIButton) {
        if arrLyric.count == 0{ warnAlert(message: "内容がない"); return}
        var subtitleStr = ""
        for check in arrLyric{
            if check != arrLyric.last!{
                subtitleStr = subtitleStr + check + "|"
            }else{
                subtitleStr += check
            }
        }
        var level = ""
        var genre = ""
        level = levelKeyboard.text
        genre = genreKeyboard.text
        
        warnAlert_YesNo(message: "保存しますか", handler: {
            (UIAlertAction) in
            if self.ifSongExist == false{
                Cloud.shared.insert(videoId: self.dicData["videoId"]!, title: self.dicData["title"]!, time: self.dicData["time"]!, imageURL: self.dicData["imageURL"]!, subtitle: subtitleStr, level: level, genre: genre, keyinDate: "", recordType: .modifyVideoInfo)
                
            }else{
                print("test3")
                Cloud.shared.update(videoId: self.dicData["videoId"]!, title: self.dicData["title"]!, time: self.dicData["time"]!, imageURL: self.dicData["imageURL"]!, subtitle: subtitleStr, level: level, genre: genre, keyinDate: "")
            }
            
            print(subtitleStr)
            print("1111")
            self.navigationController?.popViewController(animated: true)
            
        })
        
        
        
    }
    
    
    func setView(){
        lyricTableView.frame.origin.y = webView2.frame.maxY + 5
        keyinView.frame.origin.y = view.safeAreaLayoutGuide.layoutFrame.maxY - keyinView.frame.height
        lyricTableView.frame.size.height =  view.safeAreaLayoutGuide.layoutFrame.maxY - keyinView.frame.height - 5 - lyricTableView.frame.origin.y
    }

    


}
