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

protocol ServiceProtocol {

    func loadNewsPost(completion: @escaping () -> Void)
    func loadUsers(completion: @escaping () -> Void)
    func loadGroups(handler: @escaping () -> Void)
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
        
        AF.request(url, parameters: parameters).responseJSON { (response) in
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
    func loadGroups(handler: @escaping () -> Void) {
        
        let path = "/method/groups.get"
        
        let parameters = [
            "user_id": Session.connect.userId,
            "extended": "1",
            "access_token": apiKey,
            "v": "5.103"
        ]
        
        let url = baseUrl + path
        
        AF.request(url, parameters: parameters).responseJSON { [handler] (response) in
            if let error = response.error {
                print(error)
            } else {
                guard let data = response.data else { return }
                
                let groups: [Groups] = self.parserService.groupsParser(data: data)

                self.realmSevrice.saveObjects(objects: groups)
                
                handler()
            }
        }
    }
// Загрузка фотографий
    func loadPhotos(addParameters: [String: String], completion: @escaping () -> Void) {
        
        let path = "/method/photos.get"
        
        var parameters = [
            "album_id" : "profile",
            "access_token": apiKey,
            "v": "5.103"
        ]
        
        addParameters.forEach { (k,v) in parameters[k] = v }
        
        let url = baseUrl + path
        
        AF.request(url, parameters: parameters).responseJSON { [completion] (response) in
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
    
    func loadNewsPost(completion: @escaping () -> Void) {
        let path = "/method/newsfeed.get"
        
        let parameters = [
            "user_id": Session.connect.userId,
            "filters": "post",
            "access_token": apiKey,
            "v": "5.103"
        ]
        
        let url = baseUrl + path
        
        AF.request(url, parameters: parameters).responseJSON(queue: queue) { (response) in
            if let error = response.error {
                print(error)
            } else {
                guard let data = response.data else { return }
                
                let news: [NewsPost] = self.parserService.newsPostParser(data: data)
                let sourceGroup: [NewsEXT] = self.parserService.sourceGroupsParser(data: data)
                let sourceUser: [NewsEXT] = self.parserService.sourceUsersParser(data: data)
                
                self.realmSevrice.saveObjects(objects: news)
                self.realmSevrice.saveObjects(objects: sourceGroup)
                self.realmSevrice.saveObjects(objects: sourceUser)
                
                completion()
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
