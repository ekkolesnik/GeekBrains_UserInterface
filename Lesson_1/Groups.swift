//
//  Groups.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 12.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

struct Groups: Equatable {
    var name: String = ""
    var image: String = ""
    
    static func == (lhs: Groups, rhs: Groups) -> Bool {
        lhs.name == rhs.name
    }
}
