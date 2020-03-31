//
//  FriendsController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 07.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
//import SwiftyJSON

class FriendsController: UITableViewController {
    let friendService: ServiceProtocol = DataForServiceProtocol()
    
    var friends: [User] = []
    
    // массив для sectionIndexTitles
    var friendsNamesAlphabet = [Character]()
    
    //массив с именами пользователей
    var friendsNamesArray = [[String]]()
    
    //массив с именами пользователей
    var defaultfriendsNamesArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendService.loadUsers() { (users) in
            self.friends = users
            self.friendsNamesAlphabet = self.fillFriendsNamesAlphabet(friendsArray: self.friends)
            self.defaultfriendsNamesArray = self.friends
            self.tableView.reloadData()
        }
        
//        Session.connect.receiveFriendList(completion: parseFriendList)
//        searchController.searchResultsUpdater = self
//        tableView.tableHeaderView = searchController.searchBar
        
        //регистрируем xib header
        tableView.register(UINib(nibName: "FriendCellXIBView", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerView")
        
    }
    
    func fillFriendsNamesAlphabet(friendsArray: [User]) -> [Character] {
        var alphabetArray = [Character]()
        for index in 0..<friendsArray.count {
            
            let firstCharacter = friendsArray[index].firstName.first! //забираем первые символы
            alphabetArray.append(firstCharacter)
            
            }
        
        alphabetArray = Array(Set(alphabetArray)).sorted()
        
        return alphabetArray
    }
    
    // MARK: - Подготовка к перходу на CollectionView
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Получаем ссылку на контроллер, на который осуществлен переход
        guard let destination = segue.destination as? DetailedController,
            let cell = sender as? FriensCell else { return }
        
//        let friend = getFriend ( section: indexPath.section, row: indexPath.row )
//        cell.FriendsLabel.text = friend!.firstName + " " + friend!.lastName
        
        destination.nameLabelDetail = cell.FriendsLabel.text
        destination.image = cell.ImagePic.image
        destination.id = cell.id
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return friendsNamesAlphabet.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let friendsForSection = friends.filter { $0.firstName.first == friendsNamesAlphabet[section] }
        return friendsForSection.count
    }
    
//    //Вывод бокового алфавитного указателя
//    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return friendsNamesAlphabet
//    }
    
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
        //формируем title для header секций
        let headerTitle = friendsNamesAlphabet[section]
        return "\(headerTitle)"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriensCell", for: indexPath) as? FriensCell else {
            preconditionFailure("Can't create FriensCell")
        }
        
        let friendsForSection = friends.filter { $0.firstName.first == friendsNamesAlphabet[indexPath.section] }
        
        let friendName = friendsForSection[indexPath.row].firstName + " " + friendsForSection[indexPath.row].lastName
        
        let url = friendsForSection[indexPath.row].image
        
        //заполнение ячейки
        cell.FriendsLabel.text = friendName
        
        cell.id = friendsForSection[indexPath.row].id
        
        DispatchQueue.global().async {
            if let image = self.friendService.getImageByURL(imageURL: url) {
                
                DispatchQueue.main.async {
                    cell.ImagePic.image = image
                }
            }
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

//extension FriendsController : UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        guard let text = searchController.searchBar.text else { return }
//        filteredFriends = friends.reduce([String: [User]](), { (result, arg) in
//            let (key, value) = arg
//            var dict = result
//
//            let filtered = value.filter{
//                $0.firstName.lowercased().contains(text.lowercased()) ||
//                    $0.lastName.lowercased().contains(text.lowercased())
//            }
//
//            if !filtered.isEmpty {
//                dict[key] = filtered
//            }
//
//            return dict
//        })
//
//        tableView.reloadData()
//    }
//}

extension FriendsController: UISearchBarDelegate {
    
    // реализация работы поисковой строки
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText != "" {
            
            friends = friends.filter { $0.firstName.range(of: searchText, options: .caseInsensitive) != nil }
            friendsNamesAlphabet = fillFriendsNamesAlphabet(friendsArray: friends)
            
        } else {
            
            friends = defaultfriendsNamesArray
            friendsNamesAlphabet = fillFriendsNamesAlphabet(friendsArray: friends)
        }
        
        tableView.reloadData()
    }
}
