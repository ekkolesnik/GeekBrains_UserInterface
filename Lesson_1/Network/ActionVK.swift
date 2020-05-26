//
//  ActionVK.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 15.03.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RealmSwift
import PromiseKit

protocol ServiceProtocol {

    func loadNewsPost(startFrom: String, completion: @escaping (String) -> Void)
    func loadUsers(completion: @escaping () -> Void)
//    func loadGroups(handler: @escaping () -> Void)
    func loadGroups() -> Promise<[Groups]>
    func loadPhotos(addParameters: [String: String], completion: @escaping () -> Void)
    func getImageByURL(imageURL: String) -> UIImage?
}

// MARK: - Class DataForServiceProtocol: ServiceProtocol (API + Parse)

class DataForServiceProtocol: ServiceProtocol {
    
    private let queue = DispatchQueue(label: "ActionVK_queue")
    private let apiKey = Session.connect.token
    private let baseUrl = "https://api.vk.com"
    private let firebaseServise: FirebaseServise = .init()
    private let realmSevrice: RealmService = .init()
    private let parserService: ParserServiceProtocol = ParserService()
    
    enum ServiceError: Error {
        case noFound, noApiKey
    }

// Загрузка друзей
    func loadUsers(completion: @escaping () -> Void) {
        
        let path = "/method/friends.get"
        
        let parameters = [
            "user_id": Session.connect.userId,
            "order": "random",
            "fields" : "photo_200",
            "access_token": apiKey,
            "v": "5.103"
        ]
        
        let url = baseUrl + path
        
        Alamofire.request(url, parameters: parameters as Parameters).responseJSON { [completion] (response) in
            if let error = response.error {
                print(error)
            } else {
                guard let data = response.data else { return }
                
                let friends: [User] = self.parserService.usersParser(data: data)
                
                self.realmSevrice.saveObjects(objects: friends)

                completion()
            }
        }
    }
    
// Загрузка групп
    func loadGroups() -> Promise<[Groups]> {
        return Promise { (resolver) in
            
            let path = "/method/groups.get"
            
            let parameters: Parameters = [
                "user_id": String(Session.connect.userId!),
                "extended": "1",
                "access_token": String(apiKey!),
                "v": "5.103"
            ]
            
            let url = baseUrl + path
            
            Alamofire.request(url, parameters: parameters).responseJSON { (response) in
                if let error = response.error {
                    print(error)
                } else {
                    guard let data = response.data else { return }
                    
                    let groups: [Groups] = self.parserService.groupsParser(data: data)
                    
                    self.realmSevrice.saveObjects(objects: groups)
                    
                    resolver.fulfill(groups)
                }
            }
        }
    }
    
// Загрузка фотографий
    func loadPhotos(addParameters: [String: String], completion: @escaping () -> Void) {
        
        let path = "/method/photos.get"
        
        var parameters: Parameters = [
            "album_id" : "profile",
            "access_token": String(apiKey!),
            "v": "5.103"
        ]
        
        addParameters.forEach { (k,v) in parameters[k] = v }
        
        let url = baseUrl + path
        
        Alamofire.request(url, parameters: parameters).responseJSON { [completion] (response) in
            if let error = response.error {
                print(error)
            } else {
                guard let data = response.data else { return }
                
                let photos: [Photo] = self.parserService.photosParser(data: data)

                self.realmSevrice.saveObjects(objects: photos)

                completion()
            }
        }
    }
    
    func loadNewsPost( startFrom: String, completion: @escaping (String) -> Void) {
        let path = "/method/newsfeed.get"
        
        let parameters: Parameters = [
            "user_id": String(Session.connect.userId!),
            "filters": "post",
            "count": 20,
            "start_from": startFrom,
            "access_token": String(apiKey!),
            "v": "5.103"
        ]
        
        let url = baseUrl + path
        
        Alamofire.request(url, parameters: parameters).responseJSON(queue: queue) { (response) in
            if let error = response.error {
                print(error)
            } else {
                guard let data = response.data else { return }
                do {
                    let json = try JSON(data: data)
                    let nextFrom = json["response"]["next_from"].stringValue
                    let news: [NewsPost] = self.parserService.newsPostParser(json: json)
                    let sourceGroup: [NewsEXT] = self.parserService.sourceGroupsParser(json: json)
                    let sourceUser: [NewsEXT] = self.parserService.sourceUsersParser(json: json)
                    
                    self.realmSevrice.saveObjects(objects: news)
                    self.realmSevrice.saveObjects(objects: sourceGroup)
                    self.realmSevrice.saveObjects(objects: sourceUser)
                    completion(nextFrom)
                    
                } catch {
                    print(error.localizedDescription)
                    completion("")
                }
            }
        }
    }

// Функ-я перевода URL в картинку
    func getImageByURL(imageURL: String) -> UIImage? {
        let urlString = imageURL
        guard let url = URL(string: urlString) else { return nil }
        
        if let imageData: Data = try? Data(contentsOf: url) {
            return UIImage(data: imageData)
        }
        
        return nil
    }
    
}
