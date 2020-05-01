//
//  DataOperation.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 01.05.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import Alamofire

class FriendsDataOperation: AsyncOperation {
    
    var urlRequest: String
    var data: Data?
    
    let parameters = [
        "user_id": Session.connect.userId,
        "order": "random",
        "fields" : "photo_200",
        "access_token": Session.connect.token,
        "v": "5.103"
    ]
    
    override func main() {
        AF.request(urlRequest, parameters: parameters).responseJSON { response in
            self.data = response.data
            self.state = .finished
        }
    }
    
    init(reqest: String) {
        self.urlRequest = reqest
    }
}
