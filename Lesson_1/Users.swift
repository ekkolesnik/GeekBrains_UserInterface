//
//  Users.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 10.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class User: Comparable {
    
    var name: String = ""
    var lastname: String = ""
    var image: String = ""
//    let id: Int
    
    static func < (lhs: User, rhs: User) -> Bool {
     if lhs.name.startIndex < rhs.name.startIndex {
            return lhs.name < rhs.name
     } else {
        return false
        }
    }

    static func > (lhs: User, rhs: User) -> Bool {
     if lhs.name.startIndex > rhs.name.startIndex {
            return lhs.name > rhs.name
     } else {
        return false
        }
    }

    static func == (lhs: User, rhs: User) -> Bool {
        if lhs.name == rhs.name {
            return true
        } else {
            return false
        }
    }
    
    
}
