//
//  ViewController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 28.01.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var rootInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        scrollView.addGestureRecognizer(tapGesture)
            }

            override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(animated)
                
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
                
                NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            }
            
            override func viewWillDisappear(_ animated: Bool) {
                super.viewWillDisappear(animated)
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                
                NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            }
            
            @objc func keyboardWillShow(notification: Notification){
                let info = notification.userInfo! as NSDictionary
                let size = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
                
                let contentInsets = UIEdgeInsets(top: 0, left:0, bottom: size.height, right: 0)
                
                self.scrollView?.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
            }
            
            @objc func keyboardWillHide(notification: Notification){
                scrollView.contentInset = .zero
            }
            
            @objc func hideKeyboard(){
                self.scrollView.endEditing(true)
    }

    @IBAction func pushButton(_ sender: UIButton) {
        rootInfo.text = "GOOD TRY! %))"
    }
}

