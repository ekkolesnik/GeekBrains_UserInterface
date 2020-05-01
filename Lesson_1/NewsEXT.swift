//
//  NewsEXT.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 26.04.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import RealmSwift

class NewsEXT: Object {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var image: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
