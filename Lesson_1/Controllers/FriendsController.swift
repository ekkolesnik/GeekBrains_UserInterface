//
//  FriendsController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 07.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class FriendsController: UITableViewController {
    
    @IBOutlet weak var SearchBarFriends: UISearchBar!
    
    var friends = [
        User(name: "Oleg", lastname: "Makedonsky", image: UIImage(named: "img1")!, id: 1),
        User(name: "Gora", lastname: "Gregovsky", image: UIImage(named: "img2")!, id: 2),
        User(name: "Anna", lastname: "Karenina", image: UIImage(named: "img3")!, id: 3),
        User(name: "Ganna", lastname: "Agyzarova", image: UIImage(named: "img4")!, id: 4),
        User(name: "Ivan", lastname: "Urgant", image: UIImage(named: "img5")!, id: 5)
    ]
    
    lazy var friendsSorted: [String] = {
        var temp: [String] = []
        friends.forEach { friend in
            temp.append(friend.name + " " + friend.lastname)
        }
        return temp
    }()
    
    var filterFriends = [String]()
    
    lazy var sections:[[String]] = {
        
        var dict = [[String]]()
        return filterFriends.sorted().reduce([[String]]()) { (result, element) -> [[String]] in
            guard var last = result.last else { return [[element]] }
            var collection = result
            if element.first == result.last?.first?.first {
                last.append(element)
                collection[collection.count - 1] = last
            } else {
                collection.append([element])
            }
            return collection
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.SearchBarFriends.delegate = self
        
        self.filterFriends = friendsSorted
        
        //регистрируем  xib header
        tableView.register(UINib(nibName: "FriendCellXIBView", bundle: nil), forHeaderFooterViewReuseIdentifier: "headerView")
        
    }
    
    // MARK: - Подготовка к перходу на CollectionView
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Получаем ссылку на контроллер, с которого осуществлен переход
        guard let destination = segue.destination as? DetailedController else { return }

        var image: UIImage?
        var labelNameDetail: String?
        var labelLastNameDetail: String?

        for i in friends {
            if i.name + " " + i.lastname == selectedRowSuper {
                image = i.image
                labelNameDetail = i.name
                labelLastNameDetail = i.lastname
            }
        }

//        // Передаём картинку на другой контроллер
        destination.image = image
//        //Передаём имя на контроллер
        destination.nameLabelDetail = labelNameDetail
//        //Передаём Фамилию на контроллер
        destination.lastNameLabelDetail = labelLastNameDetail
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count

    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        // Делаем массив плоским
        // Например [[Москва, Мурманск], [Самара, Суздаль]] -> [Москва, Мурманск, Самара, Суздаль]
        let sectionsJoined = sections.joined()

        // Трансформируем наш "плоский" массив городов в массив первых букв названий городов
        let letterArray = sectionsJoined.compactMap{ $0.first?.uppercased() }

        // Делаем Set из массива чтобы все неуникальные буквы пропали
        let set = Set(letterArray)

        // Возвращаем массив уникальных букв предварительно его отсортировав
        return Array(set).sorted()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView")
    }
    
    //определяем нажатую ячейку для передачи её через метод "prepare"
    var selectedRowSuper: String?

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        selectedRowSuper = sections[indexPath.section][indexPath.row]
        return indexPath
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].first?.first?.uppercased()
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriensCell", for: indexPath) as? FriensCell else {
            preconditionFailure("Can't create FriensCell")
        }
        
        let users = sections[indexPath.section][indexPath.row]
        cell.FriendsLabel.text = users
        
        for i in friends {
            if i.name + " " + i.lastname == users {
                cell.ImagePic.image = i.image
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

extension FriendsController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        filterFriends = friendsSorted.filter { $0.range(of: searchText, options: .caseInsensitive) != nil }
            if filterFriends.count == 0 {filterFriends = friendsSorted}
            
            sections = {
                return filterFriends.sorted().reduce([[String]]()) { (result, element) -> [[String]] in
                    guard var last = result.last else { return [[element]] }
                    var collection = result
                    if element.first == result.last?.first?.first {
                        last.append(element)
                        collection[collection.count - 1] = last
                    } else {
                        collection.append([element])
                    }
                    return collection
                }
            }()
            tableView.reloadData()
        }
}
