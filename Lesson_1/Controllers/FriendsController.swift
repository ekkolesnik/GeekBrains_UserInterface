//
//  FriendsController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 07.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import SwiftyJSON

class FriendsController: UITableViewController {
    let FriendService: LoadFriendProtocol = LoadFriendList(parser: SwiftyJSONParserLoadFriend())
    
    @IBOutlet weak var SearchBarFriends: UISearchBar!
    
    private var friendsArray : [User] = []
    private var friends: [String: [User]] = [:]
    private var filteredFriends: [String: [User]] = [:]
    private let searchController: UISearchController = .init()
    
    var sections: [String] {
        return Array ( searchController.isActive ? filteredFriends.keys : friends.keys ).sorted ()
    }
    
    func getFriend ( section: Int, row: Int ) -> User? {
        let friendsArray = searchController.isActive ? filteredFriends : friends
        let sectionTitle = sections[section]
        let section = friendsArray[sectionTitle]
        return section?[row]
    }
    
    func parseFriendList ( json: JSON ) {
        for item in json.arrayValue {
            let firstName = item["first_name"].stringValue
            let lastName = item["last_name"].stringValue
            let photoImage = item["photo_100"].stringValue
            let letter = String ( firstName.first ?? "-" )
//            let friend = User( firstName: firstName, lastName: lastName, image: photoImage )
            let friend = User()
            friend.firstName = firstName
            friend.lastName = lastName
            friend.image = photoImage
            friendsArray.append ( friend )
            if ( friends [letter] == nil ) {
                friends [letter] = [friend]
            }
            else {
                friends [letter]?.append(friend)
            }
        }

        DispatchQueue.main.async {
            self.tableView.reloadData ()

        }
    }
    
    var cachedAvatars = [String: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Session.connect.receiveFriendList(completion: parseFriendList)
        
        searchController.searchResultsUpdater = self
        
        tableView.tableHeaderView = searchController.searchBar
        
        //регистрируем  xib header
        tableView.register(UINib(nibName: "FriendCellXIBView", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerView")
        
    }
    
    // MARK: - Подготовка к перходу на CollectionView
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Получаем ссылку на контроллер, с которого осуществлен переход
        guard let destination = segue.destination as? DetailedController,
            let cell = sender as? FriensCell
                    else { return }
        
//        let friend = getFriend ( section: indexPath.section, row: indexPath.row )
//        cell.FriendsLabel.text = friend!.firstName + " " + friend!.lastName
        
        destination.nameLabelDetail = cell.FriendsLabel.text
        destination.image = cell.ImagePic.image
//        destination.lastNameLabelDetail = cell.
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let title = sections[section]
        let array = searchController.isActive ? filteredFriends : friends
        return ( array[title] )?.count ?? 0
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView")
    }
    
    //определяем нажатую ячейку для передачи её через метод "prepare"
//    var selectedRowSuper: String?
//
//    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
//        selectedRowSuper = sections[indexPath.section][indexPath.row]
//        return indexPath
//    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    private func downloadImage( for url: String, indexPath: IndexPath ) {
        DispatchQueue.global().async {
            if let image = getImageByURL(imageUrl: url) {
                self.cachedAvatars[url] = image
                
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriensCell", for: indexPath) as? FriensCell else {
            preconditionFailure("Can't create FriensCell")
        }
        
        let friend = getFriend ( section: indexPath.section, row: indexPath.row )
        cell.FriendsLabel.text = friend!.firstName + " " + friend!.lastName
 //       cell.ImagePic.image = getImageByURL(imageUrl: friend!.image)
        
        let url = friend?.image
        
        if let cached = cachedAvatars[url!] {
            cell.ImagePic.image = cached
        }
        else {
            downloadImage(for: url!, indexPath: indexPath)
        }
        
        return cell
    }
}

//Отображение изменения цвета, радиуса и прозрачности тени

@IBDesignable class ViewImage: UIView {
    
    @IBInspectable var shadowColor: UIColor = .clear {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 6.0 {
        didSet {
            self.layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0.7 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }
}

// MARK: - UISearchBarDelegate

extension FriendsController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filteredFriends = friends.reduce([String: [User]](), { (result, arg) in
            let (key, value) = arg
            var dict = result
            
            let filtered = value.filter{
                $0.firstName.lowercased().contains(text.lowercased()) ||
                    $0.lastName.lowercased().contains(text.lowercased())
            }
            
            if !filtered.isEmpty {
                dict[key] = filtered
            }
            
            return dict
        })
        
        tableView.reloadData()
    }
}
