//
//  MyGroupCell.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 09.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class MyGroupCell: UITableViewCell {
    
    @IBOutlet weak var MyGroupNameLabel: UILabel!
    
    @IBOutlet weak var MyGroupImage: UIImageView!
    
    @IBOutlet weak var ViewImage: UIView!
    
    override func awakeFromNib() {
    super.awakeFromNib()
    
    ViewImage.layer.cornerRadius = ViewImage.frame.height / 2
    
//    ViewImage.layer.shadowColor = UIColor.black.cgColor
//    ViewImage.layer.shadowOpacity = 0.7
//    ViewImage.layer.shadowRadius = 6
    ViewImage.layer.shadowOffset = .zero
    
    MyGroupImage.layer.cornerRadius = MyGroupImage.frame.height / 2
    
    }
}
