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

class checkAuthViewController: UIViewController {
    
//    var auth_ok:Bool = false;
    let cookieStorage = HTTPCookieStorage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        if let cookies = self.cookieStorage.cookies {
            Alamofire.SessionManager.default.session.configuration.httpCookieStorage?.setCookies(cookies, for: URL(string: "http://seasonvar.ru/?mod=login") , mainDocumentURL: nil)
            
            request("http://seasonvar.ru/?mod=pause", method: .get ).responseData { response in
                
                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
//                    print("Data: \(utf8Text)")
                    
                    if utf8Text.range(of: "Премиум активен") != nil {
                        debugPrint("Auth OK: Stored")
                        if let navController = self.navigationController, let viewController = self.storyboard?.instantiateViewController(withIdentifier: "PauseViewController")
                            as? PauseViewController {
                            navController.setViewControllers([viewController], animated: true)
                        }
                    }else{
                        debugPrint("Auth ERR: Stored")
                        if let navController = self.navigationController, let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
                                   as? LoginViewController {
                           navController.setViewControllers([viewController], animated: true)
                        }
                    }
                }
                
            }
        }
    }
}
