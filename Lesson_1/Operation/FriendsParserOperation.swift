//
//  FriendsParserOperation.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 01.05.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import SwiftyJSON

class FriendsParserOperation: Operation {
    
    let realmSevice: RealmServiceProtocol = RealmService()
    var dataUser = [User]()
    
    override func main() {
        guard let friendsDataOperations = dependencies.first as? FriendsDataOperation,
            let data = friendsDataOperations.data else { return }
        
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
            
            dataUser = result
            
            try realmSevice.saveObjects(objects: dataUser)
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
