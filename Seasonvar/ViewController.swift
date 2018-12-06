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

class ViewController: UIViewController {

    struct Video {
        var title: String?
        var link: String?
    }
    
    var num:Int = 0
    var localPlayer:AVQueuePlayer = AVQueuePlayer.init()
    var queueList: [Video] = []
    var queue: [AVPlayerItem] = []
    
    @IBAction func buttonAction(_ sender: Any)
    {
//        let videoURL = URL(string: "http://data02-cdn.datalock.ru/fi2lm/243cb912a02b9b811a526d7e55eca399/7f_[AniDub].Fairy.Tail.-.010.[RUS.JAP].[1280x720.h264].[Ancord].a1.30.09.15.mp4")
//        let player = AVPlayer(url: videoURL!)
//        let playerViewController = AVPlayerViewController()
//        playerViewController.player = player
//        self.present(playerViewController, animated: true) {
//            playerViewController.player!.play()
//        }
        

        
//        queue.append(AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys))
//        queue.append(AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys))
//
  
        getJsonFromUrl();
    }
    
    @IBOutlet weak var makelist: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        self.num += 1
        print("Next Play: \(self.num)")
        self.play(playerItem: self.queue[self.num])
    }
    
    func playAll(){
        
        let queuePlayer = AVQueuePlayer(items: self.queue)
        let playerViewController = AVPlayerViewController()
        playerViewController.showsPlaybackControls = true
        playerViewController.player = queuePlayer
        present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    
    func play(playerItem: AVPlayerItem){

        let player = AVPlayer(playerItem: playerItem)

        NotificationCenter.default.addObserver(self, selector:#selector(self.playerDidFinishPlaying(note:)),name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)

        let playerViewController = AVPlayerViewController()
        playerViewController.showsPlaybackControls = true
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }

    }

    func addToQueueList(link: String, title: String ){
        if verifyUrl(urlString: link) {
            self.queueList.append(Video(title: title, link: link))
        }
    }
    
    func addToQueue(link: String, title: String){
        
        let assetKeys = [
            "playable",
            "hasProtectedContent"
        ]
        
        if verifyUrl(urlString: link) {
            print(link)
            let asset = AVAsset(url: URL(string: link)!)
            let mediaItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
            
            var allItems: [AVMetadataItem] = []
            allItems.append(self.metadataItem(identifier: AVMetadataIdentifier.commonIdentifierTitle, value: title as (NSCopying & NSObjectProtocol)?)!)
        
            allItems.append(self.metadataItem(identifier: AVMetadataIdentifier.commonIdentifierDescription, value: "" as (NSCopying & NSObjectProtocol)?)!)
            
            mediaItem.externalMetadata = allItems
            
            self.queue.append(mediaItem)
        }
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
                                            if i > 24 {
                                                self.addToQueue(link: decodedString, title: noBrTitle)
                                            }
//                                            self.addToQueueList(link: decodedString, title: title)
                                        }else{
                                            print(fileUrl)
                                            print(newString)
                                            print(newString2)
                                        }
//
                                    }
                                }
                            }
//                            if let seriesList = try? JSONSerialization.jsonObject(with: seriesArray, options: .allowFragments) as? NSArray {
                        
//                            }
//                            for series in seriesList {
//                                if let seriesDict  = series as? NSDictionary {
//                                    if let title = folder.value(forKey: "title") {
//                                        print(title as? String ?? "None")
//                                    }
//                                }
//                            }
//                            print(seriesList)
                        }
                    }
                }
            }
//            self.play(playerItem: self.queue[self.num])
            self.playAll()
        }).resume()
        
//        //fetching the data from the url
//        var Yourarray = [String]()
//
//        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
//
//            if let seriesArray = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSArray {
//
//
//                    for make in seriesArray {
//                        if let makeDict = make as? NSDictionary {
//                            if let name = makeDict.value(forKey: "title") {
//                                print(name as? String ?? "None")
//                            }
//                        }
//                    }
//
//                //printing the json in console
////                print(jsonObj!.value(forKey: "timezone")!)
//
//
//            }
//        }).resume()
        
//        makelist.beginUpdates()
//        makelist.insertRowsAtIndexPaths([
//            NSIndexPath(forRow: Yourarray.count-1, inSection: 0)], withRowAnimation: .Automatic)
//
//        makelist.endUpdates()
    }

}

