//
//  ViewController.swift
//  Seasonvar
//
//  Created by Denis Ilynikh on 03/12/2018.
//  Copyright © 2018 Denis Ilynikh. All rights reserved.
//

import UIKit
import Foundation
import AVKit
import AVFoundation
import Alamofire
import SwiftSoup 

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var SeasonImage: UIImageView!
    
    struct Video {
        var title: String?
        var link: String?
    }

    let cookieStorage = HTTPCookieStorage.shared
    var num:Int = 0
    var is_played: Bool = false;
    var queueList: [Video] = []
    var season: PauseViewController.Season!
    
    let playerViewController: AVPlayerViewController = AVPlayerViewController.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        let image = self.season.image!.replacingOccurrences(of: "small", with: "large")
        let url = URL(string: image)
        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
        SeasonImage.image = UIImage(data: data!)

//        getJsonFromUrl()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        self.num += 1
        print("Next Play: \(self.num)")
        play(series: self.num)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(is_played){
            tableView.selectRow(at: IndexPath(row: num, section: 0), animated: true, scrollPosition: UITableView.ScrollPosition.middle)
        }
    }
    
    func play(series: Int){

        if let playerItem = getMediaItem(num: series) {
            
            num = series;
            
            if(is_played){
                playerViewController.player!.replaceCurrentItem(with: playerItem)
                
                NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerViewController.player!.currentItem)
                
            }else{
                let player = AVPlayer(playerItem: playerItem)
                
                NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
                
                playerViewController.player = player
                
            }
            
            playerViewController.showsPlaybackControls = true
            dismiss(animated: true, completion: nil)
            present(playerViewController, animated: true) {
                self.playerViewController.player!.play()
                self.is_played = true;
            }
            
        }

    }

    func addToQueueList(link: String, title: String ){
        if verifyUrl(urlString: link) {
            queueList.append(Video(title: title, link: link))
        }else{
            let linksArr = link.components(separatedBy: " or ");
            if verifyUrl(urlString: linksArr[1]) {
                queueList.append(Video(title: title, link: linksArr[1]))
            }
        }
    }
    
    func getMediaItem(num: Int) -> AVPlayerItem? {
        
        let video = self.queueList[num] as Video
        
        let assetKeys = [
            "playable",
            "hasProtectedContent"
        ]
        
        if verifyUrl(urlString: video.link) {
            print(video.link!)
            let asset = AVAsset(url: URL(string: video.link!)!)
            let mediaItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
            
            var allItems: [AVMetadataItem] = []
            allItems.append(self.metadataItem(identifier: AVMetadataIdentifier.commonIdentifierTitle, value: video.title! as (NSCopying & NSObjectProtocol)?)!)
            
            allItems.append(self.metadataItem(identifier: AVMetadataIdentifier.commonIdentifierDescription, value: "" as (NSCopying & NSObjectProtocol)?)!)
            
            mediaItem.externalMetadata = allItems
            
            return mediaItem;
        }
        return nil
    }
    
    func metadataItem(identifier: AVMetadataIdentifier, value: (NSCopying & NSObjectProtocol)?) -> AVMetadataItem? {
        if let actualValue = value {
            let item = AVMutableMetadataItem()
            item.value = actualValue
            item.identifier = identifier
            item.extendedLanguageTag = "und"
            return item.copy() as? AVMetadataItem
        }
        return nil
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = URL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    //this function is fetching the json from URL
    func getSeason(season_url: String!){

        if let cookies = self.cookieStorage.cookies {
            Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookies(cookies, for: URL(string: season_url) , mainDocumentURL: nil)
            
            request(season_url, method: .get ).responseData { response in
                
                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    do {
                        let doc: Document = try SwiftSoup.parse(utf8Text)

                        let div: Elements = try doc.select("div.pgs-marks-el")
                        for block: Element in div.array() {
                            let blockHref: String = try block.select("a").attr("href")
                            let blockText: String = try block.select("div.pgs-marks-name").text()
                            let blockSeasonText: String = try block.select("div.pgs-marks-seas").text()
                            let blockImage: String = try block.select("div.pgs-marks-img").select("img").attr("src")
                        }
                        
                    } catch Exception.Error(let type, let message) {
                        print("\(type) \(message)")
                    } catch {
                        print("error")
                    }
                }
            }
        }
    }
    
    func getJsonFromUrl(){
        
        //creating a NSURL
        let url = URL(string: "http://seasonvar.ru/playls2/a4b9f2321b05ab2d6fa0f49d1fbbea1e/transAncord/2447/us1293780/plist.txt?time=1544115637")
        
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            if let foldersArray = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
                for folder in foldersArray! {
                    if let filderDict = folder as? NSDictionary {
//                        print(filderDict)
                        if let seriesArray = filderDict.value(forKey: "folder") as? NSArray {
                            var i:integer_t
                            i = 0
                            for series in seriesArray {
                                i += 1
                                if let seriesDict  = series as? NSDictionary {
                                    let title = seriesDict.value(forKey: "title") as! String
                                    let noBrTitle = title.replacingOccurrences(of: "<br>", with: " ")
                                    if let fileUrl = seriesDict.value(forKey: "file") as? String {
                                        let newString = fileUrl.replacingOccurrences(of: "#2", with: "")
                                        let newString2 = newString.replacingOccurrences(of: "//b2xvbG8=", with: "")
                                        
                                        let decodedData = Data(base64Encoded: newString2)!
                                        if let decodedString = String(data: decodedData, encoding: .utf8) {
                                            
//                                            print("\(noBrTitle) \(decodedString)")
                                            self.addToQueueList(link: decodedString, title: noBrTitle)
                                            
                                        }else{
                                            print(fileUrl)
                                            print(newString)
                                            print(newString2)
                                        }
                                    }
                                }
                            }

                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }).resume()
    
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queueList.count
    }
    
    // возвращает очередную отображаемую ячейку таблицы
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell")
        let videofile = queueList[indexPath.row]
        cell?.textLabel?.text = videofile.title
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.play(series: indexPath.row);
        
    }

}
