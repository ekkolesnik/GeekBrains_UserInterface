//
//  NewsCell.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 20.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class NewsBottomCell: UITableViewCell {
    @IBOutlet weak var heartLikeCount: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var repostCount: UILabel!
    @IBOutlet weak var viewsCount: UILabel!
}

class NewsImageCell: UITableViewCell {
    @IBOutlet weak var imageNews: UIImageView!
    
    func setImage( image: UIImage? ) {
        imageNews.image = image
    }
}

class NewsCell: UITableViewCell {
    @IBOutlet weak var FriendImageNewsCell: UIImageView!
    @IBOutlet weak var NameLabelNewsCell: UILabel!
    @IBOutlet weak var DateNewsCell: UILabel!
    @IBOutlet weak var TextNewsCell: UILabel!
    
}
