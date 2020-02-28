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
    
    @IBOutlet weak var galleryImageAfterSwipe: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Свайпы по слайдеру
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeImage(_ :)))
        swipeRight.direction = .right
        galleryImageAfterSwipe.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeImage(_ :)))
        swipeLeft.direction = .left
        galleryImageAfterSwipe.addGestureRecognizer(swipeLeft)
        
//        let gesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
//        galleryImageAfterSwipe.addGestureRecognizer(gesture)
        
    }
    
//    var interactivAnimatior: UIViewPropertyAnimator!
//
//    @objc func onPan(_ gesture: UIPanGestureRecognizer){
//        switch gesture.state {
//        case .began:
//            interactivAnimatior = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut, animations: {
//                self.galleryImage.frame = self.galleryImage.frame.offsetBy(dx: 500, dy: 0)
//            })
//            interactivAnimatior.pauseAnimation()
//        case .changed:
//            let translation = gesture.translation(in: view)
//            interactivAnimatior.fractionComplete = translation.y / 100
//        case .ended:
//            interactivAnimatior.continueAnimation(withTimingParameters: nil, durationFactor: 0)
//            
//        default:
//            return
//        }
//    }
    
    //анимация появления фото с лева на право
    func animationFotoLeftToRight() {
        galleryImageAfterSwipe.transform = CGAffineTransform(translationX: -view.bounds.width, y: 0)
        
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
            self.galleryImageAfterSwipe.transform = .identity
        })
    }
    
    //анимация появления фото с права на лево
    func animationFotoRightToLeft() {
        galleryImageAfterSwipe.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       options: .curveEaseInOut,
                       animations: {
            self.galleryImageAfterSwipe.transform = .identity
        })
    }
    
    //анимация уменьшения фото
    func animationFotoSize() {
        let scaleAnimation = CASpringAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 1
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 0.7
        scaleAnimation.stiffness = 100
        scaleAnimation.mass = 2
        scaleAnimation.beginTime = CACurrentMediaTime()
        
        galleryImage.layer.add(scaleAnimation, forKey: nil)
    }
    
    //обработка свайпов
    @objc func swipeImage(_ gesture: UISwipeGestureRecognizer) {
             
        if gesture.direction == .left {
            if indexArray >= 0 && indexArray != imageArray.count - 1 {
                
                galleryImage.image = UIImage(named: "landscape\(indexArray)")
                animationFotoSize()
                
                indexArray += 1
                
                galleryImageAfterSwipe.image = UIImage(named: "landscape\(indexArray)")
                animationFotoRightToLeft()
                
                
            } else {
                galleryImage.image = UIImage(named: "landscape\(indexArray)")
            }
            
        } else if gesture.direction == .right {
            if indexArray > 0 {
                
                galleryImage.image = UIImage(named: "landscape\(indexArray)")
                animationFotoSize()
                
                indexArray -= 1
                
                galleryImageAfterSwipe.image = UIImage(named: "landscape\(indexArray)")
                animationFotoLeftToRight()
                
                
            } else {
                galleryImage.image = UIImage(named: "landscape\(indexArray)")
            }
        }
    }
}
