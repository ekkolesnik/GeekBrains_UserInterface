//
//  VkLoginViewController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 15.03.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import WebKit

class VkLoginViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Session.connect.token != "" {
            performSegue(withIdentifier: "LoginToTabBar", sender: AnyObject.self)
        }
        
        //конструктор компонентов URL
        var components = URLComponents()
        components.scheme = "https"
        components.host = "oauth.vk.com"
        components.path = "/authorize"
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: "7359424"),
            URLQueryItem(name: "display", value: "mobile"),
            URLQueryItem(name: "redirect_uri", value: "https://oauth.vk.com/blank.html"),
            URLQueryItem(name: "scope", value: "262150"), //указываем необходимые доступа
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "v", value: "5.103"),
        ]
        
        //передаём URL для открытия на webView
        let request = URLRequest(url: components.url!)
        webView.navigationDelegate = self
        webView.load(request)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

        if Session.connect.token != "" {
            return true
        } else {
            print("Empty token")
            return false
        }
    }
}

extension VkLoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        guard let url = navigationResponse.response.url, url.path == "/blank.html", let fragment = url.fragment else {
            decisionHandler(.allow)
            return
        }
        
        // разделяем пришедший ответ на компоненты
        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { (result, param) in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
        }
        
        guard let user_id = params["user_id"] else { return }
        guard let token = params["access_token"] else { return }
        Session.connect.addTokenUserId(token: token, userId: user_id)
        decisionHandler(.cancel)
        performSegue(withIdentifier: "LoginToTabBar", sender: AnyObject.self)
    }
}
