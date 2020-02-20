//
//  MyGroupsController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 07.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class MyGroupsController: UITableViewController {
    
    @IBOutlet weak var SearchBar: UISearchBar!
    

    var myGroups = [
        Groups(name: "Клуб любителей путешествий", image: UIImage(named: "img6")!),
        Groups(name: "Однокашники", image: UIImage(named: "img8")!),
        Groups(name: "Бывалые", image: UIImage(named: "img9")!),
        Groups(name: "Худеем вместе", image: UIImage(named: "img10")!),
        Groups(name: "Кин-Дза-Дза", image: UIImage(named: "img7")!)
    ]
    
    var filterGroup = [Groups]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.SearchBar.delegate = self
        
        self.filterGroup = myGroups

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {        return 1
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
        cell.MyGroupImage.image = nameMyGroup.image

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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // Если была нажата кнопка «Удалить»
        if editingStyle == .delete {
        // Удаляем город из массива
            filterGroup.remove(at: indexPath.row)
        // И удаляем строку из таблицы
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
