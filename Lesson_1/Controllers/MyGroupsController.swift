//
//  MyGroupsController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 07.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import SwiftyJSON

class MyGroupsController: UITableViewController {
    let groupService: LoadGroupProtocol = GetFriendGroup(parser: SwiftyJSONParserLoadGroup())
    
    @IBOutlet weak var SearchBar: UISearchBar!
    

    var myGroups = [Groups]()
    
    var filterGroup = [Groups]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupService.loadDataFromVK { (groups) in
            self.myGroups = groups
            self.filterGroup = self.myGroups
            self.tableView.reloadData()
//            print(self.filterGroup)
            
        }
        
        self.SearchBar.delegate = self
        
//        self.filterGroup = myGroups

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterGroup.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyGroupCell", for: indexPath) as? MyGroupCell else {
            preconditionFailure("Can't create MyGroupCell")
        }

        let nameMyGroup = filterGroup[indexPath.row]
        cell.MyGroupNameLabel.text = nameMyGroup.name
        cell.MyGroupImage.image = getImageByURL(imageUrl: nameMyGroup.image)
//        cell.MyGroupImage.image = nameMyGroup.image

        return cell
    }
    
    // MARK: - Добавление группы
    
    @IBAction func addGroup(segue: UIStoryboardSegue) {
        
        // Проверяем идентификатор перехода, чтобы убедиться, что это нужный
        if segue.identifier == "addGroup" {
            // Получаем ссылку на контроллер, с которого осуществлен переход
            guard let availableGroupController = segue.source as? AvailableGroupsController else { return }
            // Получаем индекс выделенной ячейки
            if let indexPath = availableGroupController.tableView.indexPathForSelectedRow {
                // Получаем город по индексу
                let groups = availableGroupController.avaGroup[indexPath.row]
                // Проверяем, что такого города нет в списке
                if !filterGroup.contains(where: { $0.name == groups.name }) {
                    // Добавляем город в список выбранных
                    filterGroup.append(groups)
                    // Обновляем таблицу
                    tableView.reloadData()
                }
            }
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Если была нажата кнопка «Удалить»
        if editingStyle == .delete {
        // Удаляем город из массива
            filterGroup.remove(at: indexPath.row)
        // И удаляем строку из таблицы
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}

@IBDesignable class MyGroupViewImage: UIView {
    
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

extension MyGroupsController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        self.filterGroup.removeAll()
        
        if searchText == "" || searchText == " " {
            self.filterGroup = myGroups
            self.tableView.reloadData()
            return
        }
        
        for item in myGroups {
            let text = searchText.lowercased()
            let isArrayContain = item.name.lowercased().range(of: text)
            
            if isArrayContain != nil {
                filterGroup.append(item)
            }
        }
        self.tableView.reloadData()
    }
}
