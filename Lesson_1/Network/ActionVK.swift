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

//потом убрать
protocol ActionServiceProtocol {
    func loadDataFromVK()
}

protocol LoadDataUserProtocol {
    func loadDataFromVK(completion: @escaping ([User]) -> Void)
}

protocol UserParser {
    func parse(data: Data) -> [User]
}

protocol LoadDataGroupsProtocol {
    func loadGroupsData(completion: @escaping ([Groups]) -> Void)
}

protocol GroupsParser {
    func parse(data: Data) -> [Groups]
}

protocol SearchProtocol {
    func loadDataFromVK(_ name: String)
}

class LoadFriendList: LoadDataUserProtocol {
    let baseUrl = "https://api.vk.com"
    let parser: UserParser
    
    init(parser: UserParser) {
        self.parser = parser
    }
    
    let apiKey = Session.shared.token
    
    func loadDataFromVK(completion: @escaping ([User]) -> Void) {
        let path = "/method/friends.get"
        
        let parameters: Parameters = [
            "user_id": String(Session.shared.userId),
            "fields" : "photo_100",
            "order": "random",
            "count": "20",
            "access_token": apiKey,
            "v": "5.103"
        ]
        
        let url = baseUrl + path
        
        AF.request(url, parameters: parameters).responseJSON { [completion] (response) in
            if let error = response.error {
                print(error)
            } else {
                guard let data = response.data else { return }
                
                let users: [User] = self.parser.parse(data: data)
                
                completion(users)
                
                print(response)
            }
        }
    }
}

class UsersSwiftyJSONParser: UserParser {
    
    func parse(data: Data) -> [User] {
        do {
            let json = try JSON(data: data)
            let array = json["response"]["items"].arrayValue
            
            let result = array.map { item -> User in
                
                let user = User()
                user.name = item["first_name"].stringValue + " " + item["last_name"].stringValue
               // user.lastname = item["last_name"].stringValue
                user.image = item["photo_100"].stringValue
                
                return user
            }
            
            return result
            
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}

class LoadGroupsList: LoadDataGroupsProtocol {
    
    let baseUrl = "https://api.vk.com/method/"
    let parser: GroupsParser
    
    init(parser: GroupsParser) {
        self.parser = parser
    }
    
    let apiKey = Session.shared.token
    
    func loadGroupsData(completion: @escaping ([Groups]) -> Void) {
        
        let parameters: Parameters = [
            "extended" : 1,
            "order" : "random",
            "access_token" : apiKey,
            "v" : "5.103"
        ]
        
        let method = "groups.get"
        
        let url = baseUrl + method
        
        AF.request(url, parameters: parameters).responseJSON { [completion] (response) in
            if let error = response.error {
                print(error)
            } else {
                guard let data = response.data else { return }
                
                let groups: [Groups] = self.parser.parse(data: data)
                
                completion(groups)
            }
        }
    }
}

class GroupsSwiftyJSONParser: GroupsParser {
    
    func parse(data: Data) -> [Groups] {
        do {
            let json = try JSON(data: data)
            let array = json["response"]["items"].arrayValue
            
            let result = array.map { item -> Groups in
    
                var group = Groups()
                group.name = item["name"].stringValue
                group.image = item["photo_100"].stringValue
                
                return group
            }
            
            return result
            
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}

class GetFriendPhoto: ActionServiceProtocol {
    let baseUrl = "https://api.vk.com"
    
    let apiKey = Session.shared.token
    
    func loadDataFromVK() {
        let path = "/method/photos.getAll"
        
        let parameters = [
            "owner_id": String(Session.shared.userId),
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

class SearchGroup: SearchProtocol {
    let baseUrl = "https://api.vk.com"
    
    let apiKey = Session.shared.token
    
    func loadDataFromVK(_ name: String) {
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

func getImageByURL(imageUrl: String) -> UIImage {
    let urlString = imageUrl
    let url = NSURL(string: urlString)! as URL
    var image: UIImage = .init()
    
    if let imageData: NSData = NSData(contentsOf: url) {
        image = UIImage(data: imageData as Data)!
    }
    
    return image
}
