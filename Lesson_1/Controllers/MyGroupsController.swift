//
//  MyGroupsController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 07.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class MyGroupsController: UITableViewController {
    let groupList: LoadDataGroupsProtocol = LoadGroupsList(parser: GroupsSwiftyJSONParser())
    
    @IBOutlet weak var SearchBar: UISearchBar!
    
    var myGroups = [Groups]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        groupList.loadGroupsData() { (groups) in
            
            self.myGroups = groups
            self.tableView.reloadData()
        }
        
        self.SearchBar.delegate = self

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myGroups.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyGroupCell", for: indexPath) as? MyGroupCell else {
            preconditionFailure("Can't create MyGroupCell")
        }

            cell.MyGroupNameLabel.text = myGroups[indexPath.row].name
            cell.MyGroupImage.image = getImageByURL(imageUrl: myGroups[indexPath.row].image)

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
                if !myGroups.contains(where: { $0.name == groups.name }) {
                    // Добавляем город в список выбранных
                    myGroups.append(groups)
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
            myGroups.remove(at: indexPath.row)
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
        
        self.myGroups.removeAll()
        
        if searchText == "" || searchText == " " {
           // self.myGroups = myGroups
            self.tableView.reloadData()
            return
        }
        
        for item in myGroups {
            let text = searchText.lowercased()
            let isArrayContain = item.name.lowercased().range(of: text)
            
            if isArrayContain != nil {
                myGroups.append(item)
            }
        }
        self.tableView.reloadData()
    }
}
