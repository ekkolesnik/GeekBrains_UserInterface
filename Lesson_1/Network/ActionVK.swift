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
//    func loadNewsPhoto(completion: @escaping () -> Void)
    func loadNewsPost(completion: @escaping () -> Void)
    func loadUsers(completion: @escaping () -> Void)
    func loadGroups(handler: @escaping () -> Void)
    func loadPhotos(addParameters: [String: String], completion: @escaping () -> Void) // @escaping ([Photo])
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
                
                let friends: [User] = self.parserService.usersParser(data: data)    //usersParser(data: data)
                
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
                
                let groups: [Groups] = self.parserService.groupsParser(data: data)   //groupsParser(data: data)

                self.realmSevrice.saveObjects(objects: groups)
                
                handler()
            }
        }
    }
// Загрузка фотографий
    func loadPhotos(addParameters: [String: String], completion: @escaping () -> Void) { //@escaping ([Photo])
        
        let path = "/method/photos.get"
        
        var parameters = [
         //   "owner_id": Session.connect.userId,
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
                
                let photos: [Photo] = self.parserService.photosParser(data: data)     //photosParser(data: data)

                self.realmSevrice.saveObjects(objects: photos)

                completion() // completion(db.photoExport())
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
        
        AF.request(url, parameters: parameters).responseJSON { (response) in
            if let error = response.error {
                print(error)
            } else {
                guard let data = response.data else { return }
                
                let news: [NewsPost] = self.parserService.newsPostParser(data: data)     //newsPostParser(data: data)
                let sourceGroup: [NewsEXT] = self.parserService.sourceGroupsParser(data: data)
                let sourceUser: [NewsEXT] = self.parserService.sourceUsersParser(data: data)
                
                self.realmSevrice.saveObjects(objects: news)
                self.realmSevrice.saveObjects(objects: sourceGroup)
                self.realmSevrice.saveObjects(objects: sourceUser)
                
                completion()
            }
        }
    }
    
//    func loadNewsPhoto(completion: @escaping () -> Void) {
//        let path = "/method/newsfeed.get"
//
//        let parameters = [
//            "user_id": Session.connect.userId,
//            "filters": "photo",
//            "access_token": apiKey,
//            "v": "5.103"
//        ]
//
//        let url = baseUrl + path
//
//        AF.request(url, parameters: parameters).responseJSON { [completion] (response) in
//            if let error = response.error {
//                print(error)
//            } else {
//                guard let data = response.data else { return }
//
//                let news: [NewsPhoto] = self.newsPhotoParser(data: data)
//
//                self.realmSevrice.saveObjects(objects: news)
//
//                completion()
//            }
//        }
//    }

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

// Парсинг друзей
//    private func usersParser(data: Data) -> [User] {
//        
//        do {
//            let json = try JSON(data: data)
//            let array = json["response"]["items"].arrayValue
//            
//            let result = array.map { item -> User in
//                
//                let user = User()
//                user.id = item["id"].intValue
//                user.firstName = item["first_name"].stringValue
//                user.lastName = item["last_name"].stringValue
//                user.image = item["photo_200"].stringValue
//                
//                return user
//            }
//            
//            return result
//            
//        } catch {
//            print(error.localizedDescription)
//            return []
//        }
//    }
//    
//    private func newsPhotoParser(data: Data) -> [NewsPhoto] {
//        
//        do {
//            let json = try JSON(data: data)
//            let array = json["response"]["items"].arrayValue
//            
//            let result = array.map { item -> NewsPhoto in
//                
//                let news = NewsPhoto()
//                
//                news.postId = item["post_id"].intValue
//                news.sourceId = item["source_id"].intValue
//                news.date = item["date"].doubleValue
//                
//                let photo = item["photos"]["items"].arrayValue.first?["sizes"].arrayValue
//                if let first = photo?.first (where: { $0["type"].stringValue == "z" } ) {
//                news.imageURL = first["url"].stringValue
//                }
//                
//                news.likes = item["photos"]["items"].arrayValue.first!["likes"]["count"].intValue
//                news.comments = item["photos"]["items"].arrayValue.first!["comments"]["count"].intValue
//                news.reposts = item["photos"]["items"].arrayValue.first!["reposts"]["count"].intValue
//                
//                return news
//            }
//            
//            return result
//            
//        } catch {
//            print(error.localizedDescription)
//            return []
//        }
//    }
//    
//    private func newsPostParser(data: Data) -> [NewsPost] {
//        
//        do {
//            let json = try JSON(data: data)
//            let array = json["response"]["items"].arrayValue
//            
//            let result = array.map { item -> NewsPost in
//                
//                let news = NewsPost()
//                
//                news.postId = item["post_id"].intValue
//                news.sourceId = item["source_id"].intValue
//                news.date = item["date"].doubleValue
//                news.text = item["text"].stringValue
//                
//                let photoSet = item["attachments"].arrayValue.first?["photo"]["sizes"].arrayValue
//                if let first = photoSet?.first (where: { $0["type"].stringValue == "z" } ) {
//                    news.imageURL = first["url"].stringValue
//                }
//                
//                news.views = item["views"]["count"].intValue
//                news.likes = item["likes"]["count"].intValue
//                news.comments = item["comments"]["count"].intValue
//                news.reposts = item["reposts"]["count"].intValue
//                
//                print(news)
//                return news
//            }
//            
//            return result
//            
//        } catch {
//            print(error.localizedDescription)
//            return []
//        }
//    }
//    
//// Парсинг груп
//    private func groupsParser(data: Data) -> [Groups] {
//        
//        do {
//            let json = try JSON(data: data)
//            let array = json["response"]["items"].arrayValue
//            
//            let result = array.map { item -> Groups in
//                
//                let group = Groups()
//                
//                group.name = item["name"].stringValue
//                group.image = item["photo_100"].stringValue
//                group.id = item["id"].intValue
//                
//                firebaseServise.firebaseAddGroup(group: group)
//                
//                return group
//            }
//            return result
//            
//        } catch {
//            print(error.localizedDescription)
//            return []
//        }
//    }
//// Парсинг фотографий
//    private func photosParser(data: Data) -> [Photo] {
//        
//        do {
//            let json = try JSON(data: data)
//            let array = json["response"]["items"].arrayValue
//            
//            let result = array.map { item -> Photo in
//                
//                let photo = Photo()
//                photo.id = item["id"].intValue
//                photo.ownerId = item["owner_id"].intValue
//                
//                let sizeValues = item["sizes"].arrayValue
//                if let last = sizeValues.last {
//                    photo.imageURL = last["url"].stringValue
//                }
//                
//                return photo
//            }
//            
//            return result
//            
//        } catch {
//            print(error.localizedDescription)
//            return []
//        }
//    }
//}

// MARK: - Class DataBase for REALM

//class UsersDataBase {
//    func save( users: [User] ) throws {
//        let realm = try Realm()
//        //        print(realm.configuration.fileURL)
//        realm.beginWrite()
//        realm.add(users, update: .modified)
//        try realm.commitWrite()
//    }
//
//    func userExport() -> [User] {
//        do {
//            let realm = try Realm()
//            let objects = realm.objects(User.self)
//            return Array(objects)
//        } catch {
//            return []
//        }
//    }
//}
//
//class GroupsDataBase {
//    func save( groups: [Groups] ) throws {
//        let realm = try Realm()
//      //  print(realm.configuration.fileURL)
//        realm.beginWrite()
//        realm.add(groups, update: .modified)
//        try realm.commitWrite()
//    }
//
//    func groupExport() -> [Groups] {
//        do {
//            let realm = try Realm()
//            let objects = realm.objects(Groups.self)
//            return Array(objects)
//        } catch {
//            return []
//        }
//    }
//}
//
//class PhotoDataBase {
//    func save( photos: [Photo] ) throws {
//        let realm = try Realm()
//        realm.beginWrite()
//        let oldPhoto = realm.objects(Photo.self)
//        realm.delete(oldPhoto)
//        realm.add(photos)
//        try realm.commitWrite()
//    }
//
//    func photoExport() -> [Photo] {
//        do {
//            let realm = try Realm()
//            let objects = realm.objects(Photo.self)  //.filter("ownerId = %@", id)
//            return Array(objects)
//        } catch {
//            return []
//        }
//    }
//}
//class NewsPostDataBase {
//    func save( news: [NewsPost] ) throws {
//        let realm = try Realm()
//        realm.beginWrite()
//        realm.add(news, update: .modified)
//        try realm.commitWrite()
//    }
//
//    func newsExport() -> [NewsPost] {
//        do {
//            let realm = try Realm()
//            let objects = realm.objects(NewsPost.self)  //.filter("ownerId = %@", id)
//            return Array(objects)
//        } catch {
//            return []
//        }
//    }
//}
//
//class NewsPhotoDataBase {
//    func save( news: [NewsPhoto] ) throws {
//        let realm = try Realm()
//        realm.beginWrite()
//        realm.add(news)
//        try realm.commitWrite()
//    }
//
//    func newsExport() -> [NewsPhoto] {
//        do {
//            let realm = try Realm()
//            let objects = realm.objects(NewsPhoto.self)  //.filter("ownerId = %@", id)
//            return Array(objects)
//        } catch {
//            return []
//        }
//    }
//}

