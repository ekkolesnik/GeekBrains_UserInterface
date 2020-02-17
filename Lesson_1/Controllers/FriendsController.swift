//
//  FriendsController.swift
//  Lesson_1
//
//  Created by Evgeny Kolesnik on 07.02.2020.
//  Copyright © 2020 Evgeny Kolesnik. All rights reserved.
//

import UIKit

class FriendsController: UITableViewController {
    
    let friends = [
        User(name: "Oleg", lastname: "Makedonsky", image: UIImage(named: "img1")!),
        User(name: "Gora", lastname: "Gregovsky", image: UIImage(named: "img2")!),
        User(name: "Anna", lastname: "Karenina", image: UIImage(named: "img3")!),
        User(name: "Ganna", lastname: "Agyzarova", image: UIImage(named: "img4")!),
        User(name: "Ivan", lastname: "Urgant", image: UIImage(named: "img5")!)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Подготовка к перходу на CollectionView
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Получаем ссылку на контроллер, с которого осуществлен переход
        guard let destination = segue.destination as? DetailedController else { return }
        // Получаем индекс выделенной ячейки
        let indexPath = tableView.indexPathForSelectedRow
        // Присваеваем картинку
        let image = friends[indexPath!.row].image
        //Присваиваем имя
        let labelNameDetail = friends[indexPath!.row].name
        //присваиваем фамилию
        let labelLastNameDetail = friends[indexPath!.row].lastname
        // Передаём картинку на другой контроллер
        destination.image = image
        //Передаём имя на контроллер
        destination.nameLabelDetail = labelNameDetail
        //Передаём Фамилию на контроллер
        destination.lastNameLabelDetail = labelLastNameDetail
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriensCell", for: indexPath) as? FriensCell else {
            preconditionFailure("Can't create FriensCell")
        }
        
        let users = friends[indexPath.row]
        cell.FriendsLabel.text = users.name + " " + users.lastname
        cell.ImagePic.image = users.image
        
        return cell
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
