//
//  ImageFullScreenController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 06.03.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class ImageFullScreenController: UIViewController {
    
    let imageArray = [UIImage(named: "landscape0"), UIImage(named: "landscape1"), UIImage(named: "landscape2"), UIImage(named: "landscape3")]
    
    @IBOutlet weak var imageFull: UIImageView!
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageFull.image = image

        // Do any additional setup after loading the view.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
