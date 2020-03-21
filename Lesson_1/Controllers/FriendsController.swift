//
//  FriendsController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 07.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class FriendsController: UITableViewController {
    let friendList: LoadDataUserProtocol = LoadFriendList(parser: UsersSwiftyJSONParser())
    
    @IBOutlet weak var SearchBarFriends: UISearchBar!
    
    var friends = [User]()
    
    // создаем массив для алфавитного указателя
    var friendsNamesAlphabet = [String]()
    
    //словарь с именами пользователей
    var friendsNamesArray = [[String]]()
    
    //словарь с именами пользователей
    var defaultfriendsNamesArray = [[String]]()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendList.loadDataFromVK() { (users) in
            self.friends = users
            self.fillFriendsNamesAlphabet()
            self.fillFriendsNamesArray()
            self.defaultfriendsNamesArray = self.friendsNamesArray
            self.tableView.reloadData()
        }
        
        //регистрируем  xib header
        tableView.register(UINib(nibName: "FriendCellXIBView", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerView")
        
    }
    
    func fillFriendsNamesAlphabet() {
        for index in 0..<friends.count {
            guard let firstCharacter = friends[index].name.first else { return } //забираем первые символы
                friendsNamesAlphabet.append(String(firstCharacter))
            }
        
        friendsNamesAlphabet = Array(Set(friendsNamesAlphabet)).sorted()
    }
    
    func fillFriendsNamesArray() {
        for section in 0..<friendsNamesAlphabet.count {
            var tempString = [String]() //временный массив накопления имен
            
            for index in 0..<friends.count {
                if String(friends[index].name.first!) == friendsNamesAlphabet[section] {
                    tempString.append(String(friends[index].name))
                }
            }
            
            friendsNamesArray.append(tempString)
        }
    }
    
    // MARK: - Подготовка к перходу на CollectionView
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "DetailCon" {
            guard let friendProfileController = segue.destination as? DetailedController,
                let cell = sender as? FriensCell
                else { return }
            
            friendProfileController.nameLabelDetail = cell.FriendsLabel.text
            friendProfileController.image = cell.ImagePic.image
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
        return friendsNamesArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsNamesArray[section].count

    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return friendsNamesAlphabet
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView")
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let headerTitle = friendsNamesArray[section].first?.first else { return nil }
        return "\(headerTitle)"
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriensCell", for: indexPath) as? FriensCell else {
            preconditionFailure("Can't create FriensCell")
        }
        
        let friendName = friendsNamesArray[indexPath.section][indexPath.row]
        var friendImage: UIImage = .remove //заглушка по умолчанию
        
        //ищем в исходных данных аватар соответствующий имени пользователя
        for index in 0..<friends.count {
            if friendName == friends[index].name {
                friendImage = getImageByURL(imageUrl: friends[index].image)
            }
        }

        //заполнение ячейки
        cell.FriendsLabel.text = friendName
        cell.ImagePic.image = friendImage
        
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

extension FriendsController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    for index in 0..<friendsNamesArray.count {
        friendsNamesArray[index] = friendsNamesArray[index].filter { $0.range(of: searchText, options: .caseInsensitive) != nil }
    }
    if searchText == "" {
        friendsNamesArray = defaultfriendsNamesArray
    }
    
    tableView.reloadData()
        }
}
