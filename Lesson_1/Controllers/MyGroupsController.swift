//
//  MyGroupsController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 07.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import RealmSwift
import PromiseKit

class ImageDownloadingOperation : AsyncOperation {
    weak var groupsController: MyGroupsController?
    let url: String
    let indexPath: IndexPath
    
    init(url: String, controller: MyGroupsController, indexPath: IndexPath) {
        self.url = url
        self.groupsController = controller
        self.indexPath = indexPath
        super.init()
    }
    
    override func main() {
        if self.groupsController?.cachedAvatars[url] == nil {
            if let image = self.groupsController?.groupService.getImageByURL(imageURL: url) {
                self.groupsController?.cachedAvatars[url] = image
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if !self.isCancelled {
                        self.groupsController?.tableView.reloadRows(at: [self.indexPath], with: .automatic)
                    }
                    
                    self.state = .finished
                }
            }
        }
        else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if !self.isCancelled {
                    self.groupsController?.tableView.reloadRows(at: [self.indexPath], with: .automatic)
                }
                
                self.state = .finished
            }
        }
    }
}

class MyGroupsController: UITableViewController {
    let groupService: ServiceProtocol = DataForServiceProtocol()
    var groups: Results<Groups>?
    var groupForSearch = [Groups]()
    var notoficationToken: NotificationToken?
    let searchController = UISearchController(searchResultsController: nil)
    var cachedAvatars = [String: UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        observeMyGroup()
        groupService.loadGroups()

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        
        //Обновление данных методом свайпа вниз
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(updateGroup), for: .valueChanged)
        
        self.tableView.reloadData()
    }
    
    //функция для обновления данных методом свайпа вниз
    @objc func updateGroup() {
        groupService.loadGroups()
            self.refreshControl?.endRefreshing()
        }
    
    var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    func observeMyGroup() {
        do {
            let realm = try Realm()
            groups = realm.objects(Groups.self)
            
            notoficationToken = groups?.observe { (changes) in
                switch changes {
                case .initial:
                    self.tableView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    self.tableView.performBatchUpdates({
                        self.tableView.deleteRows(at: deletions.map{ IndexPath(row: $0, section: 0) }, with: .automatic)
                        self.tableView.insertRows(at: insertions.map{ IndexPath(row: $0, section: 0) }, with: .automatic)
                        self.tableView.reloadRows(at: modifications.map{ IndexPath(row: $0, section: 0) }, with: .automatic)
                    }, completion: nil)
                    
                case .error(let error):
                    print(error.localizedDescription)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return groupForSearch.count
        }
        return myGroupArray.count
    }
    
    //функция загрузки иконок если они отсутствуют в кэше
    let queue = OperationQueue()
    private func downloadImage( for url: String, indexPath: IndexPath ) {
        let operation = ImageDownloadingOperation(url: url, controller: self, indexPath: indexPath)
        queue.addOperation(operation)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MyGroupCell", for: indexPath) as? MyGroupCell else {
            preconditionFailure("Can't create MyGroupCell")
        }
        
        var group: Groups
        var url: String
        
        if isFiltering {
            group = groupForSearch[indexPath.row]
            url = groupForSearch[indexPath.row].image
        } else {
            group = myGroupArray[indexPath.row]
            url = myGroupArray[indexPath.row].image
        }
        
        cell.MyGroupNameLabel.text = group.name
        
        //применяем кэширование иконок групп
        if let cached = cachedAvatars[url] {
            cell.MyGroupImage.image = cached
        } else {
            downloadImage(for: url, indexPath: indexPath)
        }
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
                if !groupForSearch.contains(where: { $0.name == groups.name }) {
                    // Добавляем город в список выбранных
                    groupForSearch.append(groups)
                    // Обновляем таблицу
                    tableView.reloadData()
                }
            }
        }
    }
    
    //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //        // Если была нажата кнопка «Удалить»
    //        if editingStyle == .delete {
    //        // Удаляем город из массива
    //            filteredGroup.remove(at: indexPath.row)
    //        // И удаляем строку из таблицы
    //            tableView.deleteRows(at: [indexPath], with: .fade)
    //        }
    //    }
    
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

//extension MyGroupsController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//
//        guard let text = searchController.searchBar.text else { return }
//        groupForSearch = myGroupArray.filter({ $0.name.range(of: text, options: .caseInsensitive) != nil })
//            tableView.reloadData()
//
//    }
//}

extension MyGroupsController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        groupForSearch = myGroupArray.filter({ (groups: Groups) -> Bool in
            return groups.name.lowercased().contains(searchText.lowercased())
        })
        
        queue.cancelAllOperations()
        tableView.reloadData()
    }
}

extension MyGroupsController {
    var myGroupArray: [Groups] {
        guard let groups = groups else { return [] }
        return Array(groups)
    }
}
