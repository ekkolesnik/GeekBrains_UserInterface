//
//  NewsPhoto.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 22.04.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import RealmSwift

class NewsPhoto: Object {
    
    @objc dynamic var postId: Int = 0
    @objc dynamic var sourceId: Int = 0
    @objc dynamic var date: Double = 0
    @objc dynamic var imageURL: String = ""
    @objc dynamic var likes: Int = 0
    @objc dynamic var comments: Int = 0
    @objc dynamic var reposts: Int = 0
    
    override class func primaryKey() -> String? {
        return "postId"
    }
    
}
