//
//  DetailedCell.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 10.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class DetailedCell: UICollectionViewCell {
    
    @IBOutlet weak var DetailedImage: UIImageView!
    
    @IBOutlet weak var NameLabelDetail: UILabel!
    
    @IBOutlet weak var LastNameLabelDetail: UILabel!
    
    @IBOutlet weak var galleryButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        DetailedImage.layer.cornerRadius = DetailedImage.frame.height / 2
        
        galleryButton.layer.cornerRadius = galleryButton.frame.height / 2
        
    }
    
}

