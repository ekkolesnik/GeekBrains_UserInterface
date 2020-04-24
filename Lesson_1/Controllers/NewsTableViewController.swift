//
//  NewsTableViewController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 24.04.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit
import RealmSwift

class NewsTableViewController: UITableViewController {
    let newsService: ServiceProtocol = DataForServiceProtocol()
    var news: [Results<NewsPost>] = []
    var notoficationToken: [NotificationToken] = []
    let queueImage = DispatchQueue(label: "NewsQueue")
    
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
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(updateNews), for: .valueChanged)

    }
    
    @objc func updateNews() {
        newsService.loadNewsPost() {
            self.tableView.reloadData()
            self.prepareSections()
            self.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return news.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       // let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...
        
        let newss = news[indexPath.section][indexPath.row]
        
        let dateFormatter = DateFormatter()
        let date = NSDate(timeIntervalSince1970: newss.date)
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let stringDate = dateFormatter.string(from: date as Date)
        
        let cell = cellSelection(news: newss, indexPath: indexPath)
        
        if newss.sourceId < 0 {
            let group = self.newsService.getGroupById(id: newss.sourceId)
            cell.FriendImageNewsCell.image = newsService.getImageByURL(imageURL: group?.image ?? "")
            cell.NameLabelNewsCell.text = group?.name
            
        } else {
            let user = self.newsService.getUserById(id: newss.sourceId)
            cell.FriendImageNewsCell.image = newsService.getImageByURL(imageURL: user?.image ?? "")
            cell.NameLabelNewsCell.text = user?.lastName
        }
        
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
