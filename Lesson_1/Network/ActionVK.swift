//
//  ActionVK.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 15.03.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

protocol LoadFriendProtocol {
    //Дожидаемся загрузки данных из интернета (completion: @escaping ...)
    func loadDataFromVK(completion: @escaping ([User]) -> Void)
}

//Превращение Data в массив друзей
protocol FriendParser {
    func parse( data: Data ) -> [User]
}

protocol LoadGroupProtocol {
    //Дожидаемся загрузки данных из интернета (completion: @escaping ...)
    func loadDataFromVK(completion: @escaping ([Groups]) -> Void)
}

//Превращение Data в массив друзей
protocol GroupParser {
    func parse( data: Data ) -> [Groups]
}

protocol LoadPhotoProtocol {
    //Дожидаемся загрузки данных из интернета (completion: @escaping ...)
    func loadDataFromVK(completion: @escaping ([Photo]) -> Void)
}

//Превращение Data в массив друзей
protocol PhotoParser {
    func parse( data: Data ) -> [Photo]
}

//к удалению
protocol ActionServiceProtocol {
    func loadDataFromVK()
}

protocol SearchProtocol {
    func loadDataFromVK(_ name: String)
}

class LoadFriendList: LoadFriendProtocol {
    let baseUrl = "https://api.vk.com"
    let parser: FriendParser
    
    init(parser: FriendParser) {
        self.parser = parser
    }
    
    func loadDataFromVK(completion: @escaping ([User]) -> Void) {
        guard let apiKey = Session.connect.token else { return }
        let path = "/method/friends.get"
        
        let parameters = [
            "user_id": Session.connect.userId,
            "order": "random",
            "fields" : "photo_100",
            "access_token": apiKey,
            "v": "5.103"
        ]
        
        let url = baseUrl + path
        
        AF.request(url, parameters: parameters).responseJSON { [completion] (response) in
            if let error = response.error {
                print(error)
            } else {
                guard let data = response.data else { return }
                
                let friends: [User] = self.parser.parse(data: data)
                
                
                
                completion(friends)
            }
        }
    }
}

class SwiftyJSONParserLoadFriend: FriendParser {
    
    func parse(data: Data) -> [User] {
        do {
            let json = try JSON(data: data)
            let array = json["response"]["items"].arrayValue
            
            let result = array.map { item -> User in
                
                let user = User()
                user.firstName = item["first_name"].stringValue
                user.lastName = item["last_name"].stringValue
                user.image = item["photo_100"].stringValue
                
                return user
            }

            return result
        }
        catch {
            print(error.localizedDescription)
            return []
        }
    }
}

class GetFriendPhoto: LoadPhotoProtocol {
    let baseUrl = "https://api.vk.com"
    let parser: PhotoParser
    let db: PhotoDataBase = .init()
    
    init(parser: PhotoParser) {
        self.parser = parser
    }
    
    func loadDataFromVK(completion: @escaping ([Photo]) -> Void) {
        guard let apiKey = Session.connect.token else { return }
        let path = "/method/photos.get"
        
        let parameters = [
            "owner_id": Session.connect.userId,
            "album_id" : "profile",
            "access_token": apiKey,
            "v": "5.103"
        ]
        
        let url = baseUrl + path
        
        AF.request(url, parameters: parameters).responseJSON { [completion] (response) in
            if let error = response.error {
                print(error)
            } else {
                guard let data = response.data else { return }
                
                let photos: [Photo] = self.parser.parse(data: data)
                
                do {
                    try self.db.save(photos: photos)
                } catch {
//                                        print(self.db.photoExport())
                }
                
                completion(photos)
            }
        }
    }
}

class SwiftyJSONParserLoadPhoto: PhotoParser {
    
    func parse(data: Data) -> [Photo] {
        do {
            let json = try JSON(data: data)
            let array = json["response"]["items"].arrayValue
            print(array)
            
            let result = array.map { item -> Photo in
                
                let photos = Photo()
//                photos.image = item["url"].stringValue
                
                let sizeValues = item["sizes"].arrayValue
                if let first = sizeValues.first(where: { $0["type"].stringValue == "r" }) {
                    photos.image = first["url"].stringValue
                }
//                print(photos)
                return photos
            }

            return result
            
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}

class GetFriendGroup: LoadGroupProtocol {
    let baseUrl = "https://api.vk.com"
    let parser: GroupParser
    let db: DataBase = .init()
    
    init(parser: GroupParser) {
        self.parser = parser
    }
    
    func loadDataFromVK(completion: @escaping ([Groups]) -> Void) {
        guard let apiKey = Session.connect.token else { return }
        let path = "/method/groups.get"
        
        let parameters = [
            "user_id": Session.connect.userId,
            "extended": "1",
            "access_token": apiKey,
            "v": "5.103"
        ]
        
        let url = baseUrl + path
        
        AF.request(url, parameters: parameters).responseJSON { [completion] (response) in
            if let error = response.error {
                print(error)
            } else {
                guard let data = response.data else { return }
                
                let groups: [Groups] = self.parser.parse(data: data)
                do {
                    try self.db.save(groups: groups)
                } catch {
//                    print(self.db.groupExport())
                }
                completion(groups)
//                completion(self.db.groupExport())
            }
        }
    }
}

class SwiftyJSONParserLoadGroup: GroupParser {
    
    func parse(data: Data) -> [Groups] {
        do {
            let json = try JSON(data: data)
            let array = json["response"]["items"].arrayValue
            
            let result = array.map { item -> Groups in
                
                let groups = Groups()
                groups.name = item["name"].stringValue
                groups.image = item["photo_100"].stringValue
                
                return groups
            }

            return result
        }
        catch {
            print(error.localizedDescription)
            return []
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

func getImageByURL(imageUrl: String) -> UIImage? {
    let urlString = imageUrl
    guard let url = URL(string: urlString) else { return nil }
    
    if let imageData: Data = try? Data(contentsOf: url) {
        return UIImage(data: imageData)
    }
    
    return nil
}

class DataBase {
    func save( groups: [Groups] ) throws {
        let realm = try Realm()
        realm.beginWrite()
        realm.add(groups)
        try realm.commitWrite()
    }
    
    func groupExport() -> [Groups] {
        do {
            let realm = try Realm()
            let objects = realm.objects(Groups.self)
            return Array(objects)
        } catch {
            return []
        }
    }
}

class PhotoDataBase {
    func save( photos: [Photo] ) throws {
        let realm = try Realm()
        realm.beginWrite()
        realm.add(photos)
        try realm.commitWrite()
    }
    
    func photoExport() -> [Photo] {
        do {
            let realm = try Realm()
            let objects = realm.objects(Photo.self)
            return Array(objects)
        } catch {
            return []
        }
    }
}
