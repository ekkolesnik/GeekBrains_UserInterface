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
    let realmService: RealmServiceProtocol = RealmService()
    var news: Results<NewsPost>?
    var notoficationToken: NotificationToken?
    let queue = DispatchQueue(label: "NewsQueue")
    
    var myNewsArray: [NewsPost] {
        guard let news = news else { return [] }
        return Array(news)
    }
    
    func observeMyNews() {
        do {
            let realm = try Realm()
            news = realm.objects(NewsPost.self)
            
            notoficationToken = news?.observe { (changes) in
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsService.loadNewsPost {
            DispatchQueue.main.async {
                self.observeMyNews()
                self.tableView.reloadData()
            }
        }
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(updateNews), for: .valueChanged)
        
    }
    
    @objc func updateNews() {
        newsService.loadNewsPost() {
            DispatchQueue.main.async {
                self.observeMyNews()
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myNewsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let newss = myNewsArray[indexPath.row]
        
        let dateFormatter = DateFormatter()
        let date = NSDate(timeIntervalSince1970: newss.date)
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let stringDate = dateFormatter.string(from: date as Date)
        
        let cell = cellSelection(news: newss, indexPath: indexPath)
        
        if let newsSource = self.realmService.getNewsSourceById(id: newss.sourceId) {
            cell.NameLabelNewsCell.text = newsSource.name
            
            let imageURL = newsSource.image
            
            queue.async {
                if let image = self.newsService.getImageByURL(imageURL: imageURL) {
                    
                    DispatchQueue.main.async {
                        cell.FriendImageNewsCell.image = image
                    }
                }
            }
        }
        
        cell.DateNewsCell.text = stringDate
        cell.viewsCount.text = "\(newss.views)"
        cell.commentCount.text = "\(newss.comments)"
        cell.repostCount.text = "\(newss.reposts)"
        cell.heartLikeCount.text = "\(newss.likes)"
        
        return cell
    }
    
    func cellSelection(news: NewsPost, indexPath: IndexPath) -> NewsCell {
        
        var cell: NewsCell = .init()
        
        let imageURL = news.imageURL
        
        if news.imageURL == "" {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "NewsCellNoPhoto", for: indexPath) as! NewsCell
            
            cell.TextNewsCell.text = news.text
            
        } else if news.text == "" {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "NewsCellNoText", for: indexPath) as! NewsCell
            
            queue.async {
                if let image = self.newsService.getImageByURL(imageURL: imageURL) {
                    DispatchQueue.main.async {
                        cell.imageNews.image = image
                    }
                }
            }
            
        } else {
            
            cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
            
            cell.TextNewsCell.text = news.text
            
            queue.async {
                if let image = self.newsService.getImageByURL(imageURL: imageURL) {
                    DispatchQueue.main.async {
                        cell.imageNews.image = image
                    }
                }
            } 
        }
        
        return cell
        
    }
}
