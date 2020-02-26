//
//  DetailUserGalleryController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 26.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class DetailUserGalleryController: UIViewController {
    
    //массив картинок пользователя
    let imageArray = [UIImage(named: "landscape0"), UIImage(named: "landscape1"), UIImage(named: "landscape2"), UIImage(named: "landscape3")]
    
    //индекс для слайдера
    var indexArray = 0

    @IBOutlet weak var galleryImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Свайпы по слайдеру
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeImage(_ :)))
        swipeRight.direction = .right
        galleryImage.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeImage(_ :)))
        swipeLeft.direction = .left
        galleryImage.addGestureRecognizer(swipeLeft)
        
    }
    
    //обработка свайпов
    @objc func swipeImage(_ gesture: UISwipeGestureRecognizer) {
             
        if gesture.direction == .left {
            if indexArray >= 0 && indexArray != imageArray.count - 1 {
                indexArray += 1
                galleryImage.image = UIImage(named: "landscape\(indexArray)")
            } else {
                galleryImage.image = UIImage(named: "landscape\(indexArray)")
            }
            
        } else if gesture.direction == .right {
            if indexArray > 0 {
                indexArray -= 1
                galleryImage.image = UIImage(named: "landscape\(indexArray)")
            } else {
                galleryImage.image = UIImage(named: "landscape\(indexArray)")
            }
        }
    }
}
