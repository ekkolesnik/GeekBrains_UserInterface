//
//  News.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 20.04.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import RealmSwift

class NewsPost: Object {
    
    @objc dynamic var postId: Int = 0
    @objc dynamic var sourceId: Int = 0
    @objc dynamic var date: Double = 0
    @objc dynamic var text: String = ""
    @objc dynamic var imageURL: String = ""
    @objc dynamic var views: Int = 0
    @objc dynamic var likes: Int = 0
    @objc dynamic var comments: Int = 0
    @objc dynamic var reposts: Int = 0
    @objc dynamic var imageWidth: Double = 0.0
    @objc dynamic var imageHeight: Double = 0.0
    
    override class func primaryKey() -> String? {
        return "postId"
    }
    
    var hasImage: Bool {
        return !imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var aspectRatio: CGFloat {
        return CGFloat(imageHeight / imageWidth)
    }
    
}

