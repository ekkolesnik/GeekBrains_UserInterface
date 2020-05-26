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
    var sections: Results<NewsPost>?
    var notificationToken: NotificationToken?
    let queue = DispatchQueue(label: "NewsQueue")
    private var startFrom: String = ""
    private var loading = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }()
    
    private var cachedDates = [IndexPath: String]()
    
    var myNewsArray: [NewsPost] {
        guard let news = sections else { return [] }
        return Array(news)
    }
    
    func prepareSections() {
        do {
            let realm = try Realm()
            realm.refresh()
            sections = realm.objects(NewsPost.self).sorted(byKeyPath: "date", ascending: false)
            observeMyNews()
            tableView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func observeMyNews() {
            notificationToken = sections?.observe { [weak self] (changes) in
                switch changes {
                case .initial:
                    self?.tableView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    self?.tableView.beginUpdates()
                        self?.tableView.deleteSections(.init(deletions), with: .automatic)
                        self?.tableView.insertSections(.init(insertions), with: .automatic)
                        self?.tableView.reloadSections(.init(modifications), with: .automatic)
                    self?.tableView.endUpdates()

                case .error(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(updateNews), for: .valueChanged)
        
        loading = true
        newsService.loadNewsPost(startFrom: "") { [weak self] startFrom in
            self?.startFrom = startFrom
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                self?.prepareSections()
                self?.loading = false
            }
        }
    }
    
    @objc func updateNews() {
        loading = true
        newsService.loadNewsPost(startFrom: "") { [weak self] _ in
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                self?.prepareSections()
                self?.refreshControl?.endRefreshing()
                
                self?.loading = false
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row == 1, let news = sections?[indexPath.section], news.hasImage else { return UITableView.automaticDimension }
    
        return tableView.bounds.size.width * news.aspectRatio
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = sections?[section] else { return 0 }
        if section.hasImage {
            return 3
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let news = sections![indexPath.section]
        
        let cell = cellSelection(news: news, indexPath: indexPath)
 
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

extension NewsTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard !loading,
            let maxSection = indexPaths.map(\.section).max(),
            let sections = sections,
            maxSection > sections.count - 6 else { return }
        
        loading = true
        newsService.loadNewsPost(startFrom: startFrom) { [weak self] startFrom in
            self?.startFrom = startFrom
            self?.loading = false
        }
    }
}
