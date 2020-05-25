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
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private var cachedDates = [IndexPath: String]()
    
    var myNewsArray: [NewsPost] {
        guard let news = news else { return [] }
        return Array(news)
    }
    
    func prepareSections() {
        do {
            let realm = try Realm()
            realm.refresh()
            news = realm.objects(NewsPost.self).sorted(byKeyPath: "date", ascending: false)
            observeMyNews()
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func observeMyNews() {
            notoficationToken = news?.observe { [weak self] (changes) in
                switch changes {
                case .initial:
                    self?.tableView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    self?.tableView.performBatchUpdates({
                        self?.tableView.deleteSections(.init(deletions), with: .automatic)
                        self?.tableView.deleteSections(.init(insertions), with: .automatic)
                        self?.tableView.deleteSections(.init(modifications), with: .automatic)
                    }, completion: nil)
                    
                case .error(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newsService.loadNewsPost {
            DispatchQueue.main.async {
                self.prepareSections()
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
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return news?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row == 1, let news = news?[indexPath.section], news.hasImage else { return UITableView.automaticDimension }
    
        return tableView.bounds.size.width * news.aspectRatio
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let news = news?[section] else { return 0 }
        if news.hasImage {
            return 3
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let newss = news![indexPath.section]
        
        let cell = cellSelection(news: newss, indexPath: indexPath)
 
        
        return cell
    }
    
    func cellSelection(news: NewsPost, indexPath: IndexPath) -> UITableViewCell {
        
        let imageURL = news.imageURL
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
            cell.TextNewsCell.text = news.text
            
            //создание и кэширование даты
            if let dateString = cachedDates[indexPath] {
                cell.DateNewsCell.text = dateString
            } else {
                let date = NSDate(timeIntervalSince1970: news.date)
                let stringDate = dateFormatter.string(from: date as Date)
                cachedDates[indexPath] = stringDate
                cell.DateNewsCell.text = stringDate
            }
            if let newsSource = self.realmService.getNewsSourceById(id: news.sourceId) {
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
            
            return cell
        } else if indexPath.row == 2 || !news.hasImage {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsBottomCell", for: indexPath) as! NewsBottomCell
            
            cell.viewsCount.text = "\(news.views)"
            cell.commentCount.text = "\(news.comments)"
            cell.repostCount.text = "\(news.reposts)"
            cell.heartLikeCount.text = "\(news.likes)"
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsImageCell", for: indexPath) as! NewsImageCell
            
            queue.async {
                if let image = self.newsService.getImageByURL(imageURL: imageURL) {
                    DispatchQueue.main.async {
                        //cell.imageNews.image = image
                        cell.setImage(image: image)
                    }
                }
            } 
            
            
            return cell
            
        }
    }
}
