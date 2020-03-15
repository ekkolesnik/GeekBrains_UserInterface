//
//  ActionVK.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 15.03.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import Foundation
import Alamofire

protocol ActionServiceProtocol {
    func loadDataFromVK()
}

protocol SearchProtocol {
    func loadDataFromVK(_ name: String)
}

class LoadFriendList: ActionServiceProtocol {
    let baseUrl = "https://api.vk.com"
    
    func loadDataFromVK() {
        guard let apiKey = Session.connect.token else { return }
        let path = "/method/friends.get"
        
        let parameters = [
            "user_id": Session.connect.userId,
            "order": "random",
            "access_token": apiKey,
            "v": "5.103"
        ]
        
        let url = baseUrl + path
        
        AF.request(url, parameters: parameters).responseJSON { (response) in
            if let error = response.error {
                print(error)
            } else {
                print(response)
            }
        }
    }
}

class GetFriendPhoto: ActionServiceProtocol {
    let baseUrl = "https://api.vk.com"
    
    func loadDataFromVK() {
        guard let apiKey = Session.connect.token else { return }
        let path = "/method/photos.getAll"
        
        let parameters = [
            "owner_id": Session.connect.userId,
            "count": "20",
            "access_token": apiKey,
            "v": "5.103"
        ]
        
        let url = baseUrl + path
        
        AF.request(url, parameters: parameters).responseJSON { (response) in
            if let error = response.error {
                print(error)
            } else {
                print(response)
            }
        }
    }
}

class GetFriendGroup: ActionServiceProtocol {
    let baseUrl = "https://api.vk.com"
    
    func loadDataFromVK() {
        guard let apiKey = Session.connect.token else { return }
        let path = "/method/groups.get"
        
        let parameters = [
            "user_id": Session.connect.userId,
            "access_token": apiKey,
            "v": "5.103"
        ]
        
        let url = baseUrl + path
        
        AF.request(url, parameters: parameters).responseJSON { (response) in
            if let error = response.error {
                print(error)
            } else {
                print(response)
            }
        }
    }
}

class SearchGroup: SearchProtocol {
    let baseUrl = "https://api.vk.com"
    
    func loadDataFromVK(_ name: String) {
        guard let apiKey = Session.connect.token else { return }
        let path = "/method/groups.search"
        
        let parameters = [
            "q": "Плавание",
            "access_token": apiKey,
            "v": "5.103"
        ]
        
        let url = baseUrl + path
        
        AF.request(url, parameters: parameters).responseJSON { (response) in
            if let error = response.error {
                print(error)
            } else {
                print(response)
            }
        }
    }
}
