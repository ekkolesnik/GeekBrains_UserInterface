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
        
        //добавляем GestureRecognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageOnTap))
        ViewImage.addGestureRecognizer(tapGesture)
        ViewImage.isUserInteractionEnabled = true
        
        ViewImage.layer.cornerRadius = ViewImage.frame.height / 2
        
        //   ViewImage.layer.shadowColor = UIColor.black.cgColor
        //   ViewImage.layer.shadowOpacity = 0.7
        //   ViewImage.layer.shadowRadius = 6
        ViewImage.layer.shadowOffset = .zero
        
        avaGroupImage.layer.cornerRadius = avaGroupImage.frame.height / 2
        
    }
    
    //функ-я обработки нажатия на иконку группы
    @objc func imageOnTap(){
        
        UIView.animate(withDuration: 0.2, delay: 0.0, animations: {
            self.ViewImage.transform = .init(scaleX: 0.9, y: 0.9)
        })
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 20, animations: {
            self.ViewImage.transform = .init(scaleX: 1, y: 1)
        })
        
    }
    
}
