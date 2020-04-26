//
//  FirebaseConnect.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 12.04.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

protocol FirebaseConnectProtocol {
    func firebaseAuth()
    func firebaseAddGroup(group: Groups)
    func updateNewsSource(object: NewsEXT)
}

class FirebaseServise: FirebaseConnectProtocol {
    let db = Database.database().reference()
    var userID = ""
    
    //Получаем данные по анонимному пользователю
    func firebaseAuth() {
        Auth.auth().signInAnonymously() { (authResult, error) in
            guard let user = authResult?.user else { return }
            let uid = user.uid
            self.userID = user.uid
            
            //Получаем путь до пользователя
            let appUsersPath = self.db.child("USER")
            if appUsersPath.isEqual( "\(uid)" ) == false {
                appUsersPath.child("\(uid)").updateChildValues([ "device" : "\(uid)" ])
            }
        }
    }
    
    func firebaseAddGroup(group: Groups) {
        let groupsPath = self.db.queryOrdered(byChild: "USER/\(userID)/groups")
        if groupsPath.isEqual("\(group.name)") == false {
            db.child("USER/\(userID)/groups/\(group.id)").updateChildValues([ "name" : "\(group.name)" ])
        }
    }
    
    func updateNewsSource(object: NewsEXT) {
        
        
        let newsSourcesPath = self.db.queryOrdered(byChild: "appusers/\(self.userID)/newsSources")
        
        if newsSourcesPath.isEqual("\(object.id)") == false {
            
            self.db.child("appusers/\(self.userID)/newsSources/\(object.id)").updateChildValues([ "id" : "\(object.id)" ])
            self.db.child("appusers/\(self.userID)/newsSources/\(object.id)").updateChildValues([ "name" : "\(object.name)" ])
            
        }
        
    }
    
}
