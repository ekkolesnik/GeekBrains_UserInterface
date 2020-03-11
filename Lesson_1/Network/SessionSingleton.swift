//
//  SessionSingleton.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 11.03.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class Session {

    static let connect: Session = .init()
    var token: String?
    var userId: Int?
    
    func addTokenUserId( token: String, userId: Int) {
        self.token = token
        self.userId = userId
    }
    
    private init() {}
}

