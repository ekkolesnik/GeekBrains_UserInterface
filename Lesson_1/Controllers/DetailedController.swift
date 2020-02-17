//
//  DetailedController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 07.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class DetailedController: UICollectionViewController {
    
    var image: UIImage?
    var nameLabelDetail: String?
    var lastNameLabelDetail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailedCell", for: indexPath) as! DetailedCell
        
        cell.DetailedImage.image = image
        cell.NameLabelDetail.text = nameLabelDetail
        cell.LastNameLabelDetail.text = lastNameLabelDetail
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
}

//extension UIBezierPath {
//    convenience init(heartIn rect: CGRect) {
//        self.init()
//
//        //Calculate Radius of Arcs using Pythagoras
//        let sideOne = rect.width * 0.4
//        let sideTwo = rect.height * 0.3
//        let arcRadius = sqrt(sideOne*sideOne + sideTwo*sideTwo)/2
//
//        //Left Hand Curve
//        self.addArc(withCenter: CGPoint(x: rect.width * 0.3, y: rect.height * 0.35), radius: arcRadius, startAngle: 135.degreesToRadians, endAngle: 315.degreesToRadians, clockwise: true)
//
//        //Top Centre Dip
//        self.addLine(to: CGPoint(x: rect.width/2, y: rect.height * 0.2))
//
//        //Right Hand Curve
//        self.addArc(withCenter: CGPoint(x: rect.width * 0.7, y: rect.height * 0.35), radius: arcRadius, startAngle: 225.degreesToRadians, endAngle: 45.degreesToRadians, clockwise: true)
//
//        //Right Bottom Line
//        self.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.95))
//
//        //Left Bottom Line
//        self.close()
//    }
//}
//
//extension Int {
//    var degreesToRadians: CGFloat { return CGFloat(self) * .pi / 180 }
//}
//
//
//class heartView: UIView {
//    
//    override func draw(_ rect: CGRect) {
//    super.draw(rect)
//        
//        guard let context = UIGraphicsGetCurrentContext() else { return }
//            context.setStrokeColor(UIColor.red.cgColor)
//            
////        func drawHeart (){
////            self.tintColor.setFill()
////            path.fill()
////        }
//        let path = UIBezierPath(heartIn: self.bounds)
//        path.stroke()
//        
//        //заполнение красным
//        self.tintColor.setFill()
//        path.fill()
//        
//    }
//}
