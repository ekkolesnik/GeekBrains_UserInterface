//
//  SessionSingleton.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 11.03.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class Session {
    
    var token: String = .init()
    var userId: Int = .init()
    
    private init() {}
    
    static let shared: Session = .init()
    
}

