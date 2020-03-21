//
//  ActionVkViewController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 15.03.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class ActionVkViewController: UIViewController {
    
    @IBOutlet weak var groupTextField: UITextField!
    
    let friendPhoto: ActionServiceProtocol = GetFriendPhoto()
  //  let friendList: LoadDataUserProtocol = LoadFriendList(parser: UsersSwiftyJSONParser())
  //  let friendGroup: ActionServiceProtocol = GetFriendGroup()
    let searchGroup: SearchProtocol = SearchGroup()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func friendListButtonAction(_ sender: Any) {
     //   friendList.loadDataFromVK(completion: ([User]) -> Void)
    }
    
    @IBAction func friendPhotoButton(_ sender: Any) {
        friendPhoto.loadDataFromVK()
    }
    
    @IBAction func friendGroupButton(_ sender: Any) {
     //   friendGroup.loadDataFromVK()
    }
    
    @IBAction func searchGroupButton(_ sender: Any) {
        searchGroup.loadDataFromVK(groupTextField.text!)
    }
    
}
