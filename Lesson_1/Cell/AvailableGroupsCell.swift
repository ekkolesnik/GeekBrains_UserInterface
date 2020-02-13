//
//  AvailableGroupsCell.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 10.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class AvailableGroupsCell: UITableViewCell {

    @IBOutlet weak var avaGroupName: UILabel!
    
    @IBOutlet weak var avaGroupImage: UIImageView!
    
    @IBOutlet weak var ViewImage: UIView!
    
    override func awakeFromNib() {
    super.awakeFromNib()
    
    ViewImage.layer.cornerRadius = ViewImage.frame.height / 2
    
    ViewImage.layer.shadowColor = UIColor.black.cgColor
    ViewImage.layer.shadowOpacity = 0.7
    ViewImage.layer.shadowRadius = 6
    ViewImage.layer.shadowOffset = .zero
    
    avaGroupImage.layer.cornerRadius = avaGroupImage.frame.height / 2
    
    }
    
}
