//
//  NewsController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 19.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import RealmSwift

class NewsController: UIViewController {
    let newsService: ServiceProtocol = DataForServiceProtocol()
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    var refreshControl = UIRefreshControl()
    
    var news: [Results<NewsPost>] = []
    
//    var source: Object?
    
//    var newsArray: [NewsPost] {
//        guard let news = news else { return [] }
//        return Array(news)
//    }
    
    var notoficationToken: [NotificationToken] = []
    
    func prepareSections() {
        
        do {
            notoficationToken.removeAll()
            let realm = try Realm()
            news = Array( arrayLiteral: realm.objects(NewsPost.self).sorted(byKeyPath: "date", ascending: false) )
            news.enumerated().forEach{ observeChanges(section: $0.offset, results: $0.element) }
            tableView.reloadData()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func observeChanges(section: Int, results: Results<NewsPost>) {
        notoficationToken.append(
            results.observe { (changes) in
                switch changes {
                case .initial:
                    self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
                    
                case .update(_, let deletions, let insertions, let modifications):
                    self.tableView.beginUpdates()
                    self.tableView.deleteRows(at: deletions.map{ IndexPath(row: $0, section: section) }, with: .automatic)
                    self.tableView.insertRows(at: insertions.map{ IndexPath(row: $0, section: section) }, with: .automatic)
                    self.tableView.reloadRows(at: modifications.map{ IndexPath(row: $0, section: section) }, with: .automatic)
                    self.tableView.endUpdates()
                
                case .error(let error):
                    print(error.localizedDescription)
                
                }
            }
        )
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsService.loadNewsPost {
            self.tableView.reloadData()
            self.prepareSections()
        }
        
        
        // Автоматический подбор высоты ячейки по содержанию
 //       tableView.rowHeight = UITableView.automaticDimension
        
        //Обновление данных методом свайпа вниз
        refreshControl.addTarget(self, action: #selector(updateNews), for: .valueChanged)

    }
    
    //функция для обновления данных методом свайпа вниз
    @objc func updateNews() {
        newsService.loadNewsPost() { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
}

extension NewsController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as? NewsCell else {
//            preconditionFailure("Can't create NewsCell")
//        }
        
        let newss = news[indexPath.section][indexPath.row]
        print(news)
        
        let dateFormatter = DateFormatter()
        let date = NSDate(timeIntervalSince1970: newss.date)
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let stringDate = dateFormatter.string(from: date as Date)
        
        let cell = cellSelection(news: newss, indexPath: indexPath)
        
        cell.DateNewsCell.text = stringDate
        
        
        return cell
    }
    
    func cellSelection(news: NewsPost, indexPath: IndexPath) -> NewsCell {
        
      var cell: NewsCell = .init()
        
        if news.imageURL == "" {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "NewsCellNoPhoto", for: indexPath) as! NewsCell
            
            cell.TextNewsCell.text = news.text
            
        } else if news.text == "" {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "NewsCellNoText", for: indexPath) as! NewsCell
            
            cell.imageNews.image = newsService.getImageByURL(imageURL: news.imageURL)

        } else {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
            
            cell.TextNewsCell.text = news.text
            cell.imageNews.image = newsService.getImageByURL(imageURL: news.imageURL)
            
        }
        
        return cell
        
    }
    
}
