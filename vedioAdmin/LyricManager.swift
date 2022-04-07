//
//  LyricManager.swift
//  vedioAdmin
//
//  Created by 朱偉綸 on 2021/6/1.
//

import Foundation
import UIKit
import YoutubePlayer_in_WKWebView
import AVFoundation
import MediaPlayer
import WebKit

class LyricManager{
    static let shared = LyricManager()
    
    func selectLyric(playLyric: Array<String>, myWebView:WKYTPlayerView, lyricTableView:UITableView){
        myWebView.getCurrentTime { (floatValue, error) in
            if error == nil{
                var count = 0
                for i in playLyric{
                    if Int(i.components(separatedBy: "_")[0]) == Int(floatValue){
                        lyricTableView.scrollToRow(at: IndexPath(row: count, section: 0), at: .middle, animated: true)
                        lyricTableView.selectRow(at: IndexPath(row: count, section: 0), animated: true, scrollPosition: .none)
                    }
                    count += 1
                }
            }
        }
    }

    func clickToSeconds(myWebView:WKYTPlayerView, arrLyric:Array<String>, indexPath: IndexPath){
        for countArr in 0 ... (arrLyric.count - 1){
            if countArr == indexPath.row{
                if let seconds = Float(arrLyric[countArr].components(separatedBy: "_")[0]){
                    myWebView.seek(toSeconds: seconds, allowSeekAhead: true)
                    break
                }
            }
        }
    }
    
    
    
    
    
    
    
    
}
