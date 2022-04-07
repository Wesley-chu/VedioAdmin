//
//  videoViewController.swift
//  vedioAdmin
//
//  Created by 朱偉綸 on 2021/6/1.
//

import UIKit
import WebKit
import AVFoundation
import MediaPlayer
import YoutubePlayer_in_WKWebView

class VideoViewController: UIViewController,WKYTPlayerViewDelegate,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var myWebView: WKYTPlayerView!
    @IBOutlet weak var lyricTableView: UITableView!
    
    let playerVars = [
        "playsinline" : 1,
        ]
    
    var arrId_Lyric = [String]()
    var keyId = ""
    var arrIndex = [String]()
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyId = arrId_Lyric[0]
        arrIndex = arrId_Lyric[1].components(separatedBy: "|")
        
        myWebView.delegate = self
        lyricTableView.delegate = self
        lyricTableView.dataSource = self
        play(webURL: keyId)
        
        
    }
    
    func play(webURL:String){
        myWebView.load(withVideoId: webURL, playerVars: playerVars)
    }
    
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        myWebView.playVideo()
    }
    
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        switch(state) {
        case WKYTPlayerState.playing:
            print("Video playing")
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (Timer) in
                LyricManager.shared.selectLyric(playLyric: self.arrIndex, myWebView: self.myWebView, lyricTableView: self.lyricTableView)
            })
        case WKYTPlayerState.paused:
            print("Video paused")
        case WKYTPlayerState.unstarted:
            print("Video unstarted")
        case WKYTPlayerState.queued:
            print("Video queued")
        case WKYTPlayerState.buffering:
            print("Video buffering")
        case WKYTPlayerState.ended:
            print("Video ended")
        default:
            print("Video others")
            break
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrIndex.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = lyricTableView.dequeueReusableCell(withIdentifier: "cell5", for: indexPath)
        
        guard let textLabel = cell.contentView.subviews[0] as? UILabel else { return cell }
        textLabel.text = String(arrIndex[indexPath.row].components(separatedBy: "_")[1]) + "\n"
            + String(arrIndex[indexPath.row].components(separatedBy: "_")[2])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if timer != nil{ timer!.invalidate() }
        
        LyricManager.shared.clickToSeconds(myWebView: myWebView, arrLyric: arrIndex, indexPath: indexPath)
    }
    
    
    
    
    


}
