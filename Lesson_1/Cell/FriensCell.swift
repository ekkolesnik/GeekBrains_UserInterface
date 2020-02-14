//
//  FriensCell.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 07.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class FriensCell: UITableViewCell {
    
    

    @IBOutlet weak var FriendsLabel: UILabel!
   
    @IBOutlet weak var ImagePic: UIImageView!
    
    @IBOutlet weak var ViewImage: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ViewImage.layer.cornerRadius = ViewImage.frame.height / 2
        
//        ViewImage.layer.shadowColor = UIColor.black.cgColor
//        ViewImage.layer.shadowOpacity = 0.7
//        ViewImage.layer.shadowRadius = 6
        ViewImage.layer.shadowOffset = .zero
        
        ImagePic.layer.cornerRadius = ImagePic.frame.height / 2
        
    }
}
