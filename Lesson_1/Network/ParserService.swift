//
//  ParserService.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 26.04.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import SwiftyJSON

protocol ParserServiceProtocol {
    func usersParser(data: Data) -> [User]
    func groupsParser(data: Data) -> [Groups]
    func photosParser(data: Data) -> [Photo]
    func newsPostParser(json: JSON) -> [NewsPost]
    func sourceGroupsParser(json: JSON) -> [NewsEXT]
    func sourceUsersParser(json: JSON) -> [NewsEXT]
}

class ParserService: ParserServiceProtocol {
    private let firebaseService: FirebaseConnectProtocol = FirebaseServise()
    
    func usersParser(data: Data) -> [User] {
        do {
            let json = try JSON(data: data)
            let array = json["response"]["items"].arrayValue
            
            let result = array.map { item -> User in
                
                let user = User()
                user.id = item["id"].intValue
                user.firstName = item["first_name"].stringValue
                user.lastName = item["last_name"].stringValue
                user.image = item["photo_200"].stringValue
                
                return user
            }
            
            return result
            
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func groupsParser(data: Data) -> [Groups] {
        do {
            let json = try JSON(data: data)
            let array = json["response"]["items"].arrayValue
            
            let result = array.map { item -> Groups in
                
                let group = Groups()
                
                group.name = item["name"].stringValue
                group.image = item["photo_100"].stringValue
                group.id = item["id"].intValue
                
                firebaseService.firebaseAddGroup(group: group)
                
                return group
            }
            return result
            
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func photosParser(data: Data) -> [Photo] {
        do {
            let json = try JSON(data: data)
            let array = json["response"]["items"].arrayValue
            
            let result = array.map { item -> Photo in
                
                let photo = Photo()
                photo.id = item["id"].intValue
                photo.ownerId = item["owner_id"].intValue
                
                let sizeValues = item["sizes"].arrayValue
                if let last = sizeValues.last {
                    photo.imageURL = last["url"].stringValue
                }
                
                return photo
            }
            
            return result
            
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    func newsPostParser(json: JSON) -> [NewsPost] {
        let array = json["response"]["items"].arrayValue
        
        let result = array.map { item -> NewsPost in
            
            let news = NewsPost()
            
            news.postId = item["post_id"].intValue
            news.sourceId = item["source_id"].intValue
            news.date = item["date"].doubleValue
            news.text = item["text"].stringValue
            
            let photoSet = item["attachments"].arrayValue.first?["photo"]["sizes"].arrayValue
            if let first = photoSet?.first (where: { $0["type"].stringValue == "z" } ) {
                news.imageURL = first["url"].stringValue
                news.imageWidth = first["width"].doubleValue
                news.imageHeight = first["height"].doubleValue
            }
            
            news.views = item["views"]["count"].intValue
            news.likes = item["likes"]["count"].intValue
            news.comments = item["comments"]["count"].intValue
            news.reposts = item["reposts"]["count"].intValue
            
            return news
        }
        
        return result
        
    }
    
    func sourceGroupsParser(json: JSON) -> [NewsEXT] {
        let array = json["response"]["groups"].arrayValue
        
        let result = array.map { item -> NewsEXT in
            
            let sourceGroup = NewsEXT()
            
            sourceGroup.id = item["id"].intValue
            sourceGroup.name = item["name"].stringValue
            sourceGroup.image = item["photo_200"].stringValue
            
            firebaseService.updateNewsSource(object: sourceGroup)
            
            return sourceGroup
        }
        
        return result
        
    }
    
    func sourceUsersParser(json: JSON) -> [NewsEXT] {
        let array = json["response"]["profiles"].arrayValue
        
        let result = array.map { item -> NewsEXT in
            
            let sourceUser = NewsEXT()
            sourceUser.id = item["id"].intValue
            sourceUser.name = item["first_name"].stringValue + " " + item["last_name"].stringValue
            sourceUser.image = item["photo_100"].stringValue
            
            firebaseService.updateNewsSource(object: sourceUser)
            
            return sourceUser
        }
        
        return result
        
    }
    
}

