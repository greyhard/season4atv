//
//  LoginViewController.swift
//  Seasonvar
//
//  Created by Denis Ilynikh on 23/12/2018.
//  Copyright © 2018 Denis Ilynikh. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    let cookieStorage = HTTPCookieStorage.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBOutlet weak var Login: UITextField!
    @IBOutlet weak var Password: UITextField!
    
    @IBAction func Login(_ sender: UIButton) {
        
        if let login_text = Login.text, let password_text = Password.text {
        
            let parameters: Parameters = [
                "login": login_text,
                "password": password_text
            ]

            request("http://seasonvar.ru/?mod=login", method: .post, parameters: parameters).responseData { response in

                if let data = response.result.value, let utf8Text = String(data: data, encoding: .utf8) {
                    if utf8Text.range(of: login_text) != nil {
                        if let
                            headerFields = response.response?.allHeaderFields as? [String: String],
                            let URL = response.request?.url
                        {
                            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headerFields, for: URL)
                            //                            debugPrint(cookies)
                            self.cookieStorage.setCookies(cookies,
                                                          for: URL,
                                                          mainDocumentURL: nil)
                            debugPrint("Auth OK")
                            if let navController = self.navigationController, let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")
                                as? ViewController {
                                    navController.pushViewController(viewController, animated: true)
                            }
                        }
                    }
                }
            }
        }
        

    }
    
}
