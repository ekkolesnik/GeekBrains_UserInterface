//
//  RealmService.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 26.04.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import RealmSwift

protocol RealmServiceProtocol {
    func getGroupById(id: Int) -> Groups?
    func getUserById(id: Int) -> User?
    func saveObjects(objects: [Object]) throws
    func getNewsSourceById(id: Int) -> NewsEXT?
    func getUserPhotos(ownerId: Int) -> [Photo]
}

class RealmService: RealmServiceProtocol {
    
    func getGroupById(id: Int) -> Groups? {
        do {
            let realm = try Realm()
            let group = realm.objects(Groups.self).filter("id = %@", abs(id)).first
            return group
            
        } catch {
            print(error.localizedDescription)
            return Groups()
        }
    }
    
    func getUserById(id: Int) -> User? {
        do {
            let realm = try Realm()
            let user = realm.objects(User.self).filter("id = %@", abs(id)).first
            return user
            
        } catch {
            print(error.localizedDescription)
            return User()
        }
    }
    
    func saveObjects(objects: [Object]) {
        do {
            Realm.Configuration.defaultConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            let realm = try Realm()
          //  print(realm.configuration.fileURL)
            realm.beginWrite()
            realm.add(objects, update: .modified)
            try realm.commitWrite()
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func getNewsSourceById(id: Int) -> NewsEXT? {
        do {
            let realm = try Realm()
            let newsEXT = realm.objects(NewsEXT.self).filter("id = %@", abs(id)).first
            return newsEXT
            
        } catch {
            print(error.localizedDescription)
            return NewsEXT()
        }
    }
    
    func getUserPhotos(ownerId: Int) -> [Photo] {
        do {
            let realm = try Realm()
            let photos = realm.objects(Photo.self).filter("ownerId = %@", ownerId)
            return Array(photos)
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
}


