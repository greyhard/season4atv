//
//  anotherStoryBoard.swift
//  Seasonvar
//
//  Created by Denis Ilynikh on 17/12/2018.
//  Copyright © 2018 Denis Ilynikh. All rights reserved.
//
//
//  ViewController.swift
//  Seasonvar
//
//  Created by Denis Ilynikh on 03/12/2018.
//  Copyright © 2018 Denis Ilynikh. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup 

class PauseViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    struct Season {
        var href: String?
        var image: String?
        var season_text: String?
        var name: String?
    }
    
    var pauseList: [Season] = []
    var currentSeason: Season!
    
    @IBOutlet weak var pauseTableView: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pauseList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = pauseTableView.dequeueReusableCell(withIdentifier: "pauseCell")
        let season = pauseList[indexPath.row]
        cell?.textLabel?.text = "\(season.name ?? ""): \(season.season_text ?? "")"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.currentSeason = pauseList[indexPath.row];
        
        if let navController = self.navigationController, let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
            as? ViewController {
            viewController.season = self.currentSeason
            navController.pushViewController(viewController, animated: true)
        }
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let controller = segue.destination as? ViewController {
//            print(self.currentSeason)
//            controller.season_href = self.currentSeason.href
//        }
//    }
    
    //    var auth_ok:Bool = false;
    let cookieStorage = HTTPCookieStorage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pauseTableView.delegate = self
        self.pauseTableView.dataSource = self
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
        
        if let cookies = self.cookieStorage.cookies {
            Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookies(cookies, for: URL(string: "http://seasonvar.ru/?mod=login") , mainDocumentURL: nil)
            
            request("http://seasonvar.ru/?mod=pause", method: .get ).responseData { response in
                
                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    do {
                        let doc: Document = try SwiftSoup.parse(utf8Text)
//                        let text: String = try doc.select("li.headmenu-title").text()
//                        print(text)
                        
                        
                        let div: Elements = try doc.select("div.pgs-marks-el")
                        for block: Element in div.array() {
                            let blockHref: String = try block.select("a").attr("href")
                            let blockText: String = try block.select("div.pgs-marks-name").text()
                            let blockSeasonText: String = try block.select("div.pgs-marks-seas").text()
                            let blockImage: String = try block.select("div.pgs-marks-img").select("img").attr("src")
//                            print("\(blockText) \(blockSeasonText) \(blockHref) \(blockImage)")
                            self.pauseList.append(Season(href: blockHref, image: blockImage, season_text: blockSeasonText, name: blockText))
                            
                        }
                        
                        DispatchQueue.main.async {
                            self.pauseTableView.reloadData()
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
}
