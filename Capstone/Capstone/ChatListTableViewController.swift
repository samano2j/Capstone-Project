//
//  ChatListTableViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-03-05.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit
import SparrowKit
import SPStorkController

class ChatListTableViewController: UITableViewController {
//    let navBar = SPFakeBarView.init(style: .stork)
//    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        let edit = self.editButtonItem
        let compose = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addTapped))
        self.navigationItem.rightBarButtonItems = [edit, compose]
        
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.tableFooterView = UIView()
        self.toolbarItems = nil
        
        
        super.viewDidLoad()
//        self.modalPresentationCapturesStatusBarAppearance = true
//
//        self.navBar.titleLabel.text = "New Message"
//        self.navBar.leftButton.setTitle("Cancel", for: .normal)
//        self.navBar.rightButton.setTitle("Send", for: .normal)
//        self.navBar.leftButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
//        self.navBar.rightButton.addTarget(self, action: #selector(self.cancel), for: .touchUpInside)
//
//        self.view.addSubview(self.navBar)
    }
    
    @objc func cancel() {
    }
    
    @objc func addTapped() {
    }
    
    func getCustomImage(imageDisplayName: String?, imageView: UIImageView!){
        if let name = imageDisplayName, !name.isEmpty {
            imageView.setImage(string:name, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), circular: true, stroke: true)
        } else {
            imageView.setImage(string:"Display Picture", color: UIColor.colorHash(name: "Display Picture"), circular: true, stroke: true)
        }
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
        
        let readAll = UIBarButtonItem(title: "Read All", style: .plain, target: self, action: #selector(addTapped))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let delete = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(addTapped))
        
        if (tableView.isEditing) {
            self.toolbarItems = [readAll, spacer, delete]
        } else {
            self.toolbarItems = []
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return MockChatMeassages.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatKitCell", for: indexPath) as! ChatKitMessagesListCell
        cell.senderName.text = MockChatMeassages[indexPath.row].name
        cell.resentMessage.text = MockChatMeassages[indexPath.row].message
        cell.messagesDate.text = MockChatMeassages[indexPath.row].relativeChatDateString
        //let imageView = cell.imageView
        getCustomImage(imageDisplayName: MockChatMeassages[indexPath.row].name, imageView: cell.messageAvatar)

        return cell
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
        if editingStyle == .delete {
            // Delete the row from the data source
            MockChatMeassages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !tableView.isEditing
    }

}

class ChatKitMessagesListCell: UITableViewCell {
    @IBOutlet weak var messageAvatar: UIImageView!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var resentMessage: UILabel!
    @IBOutlet weak var messagesDate: UILabel!
    
}

class ChatMessage: NSObject {
    let name: String
    let message: String
    let date: Date
    
    init(name: String, message: String, date: Date) {
        self.name = name
        self.message = message
        self.date = date
    }
    
    var relativeChatDateString: String {
        if Calendar.current.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: date)
        }
    }
    
}


var MockChatMeassages: [ChatMessage] = [ChatMessage(name: "Ives_fuego", message: "hello, i was wondering if you could help me get some drugs from the store", date: Date.distantPast), ChatMessage(name: "Robin Hood", message: "I always feel happy, you know why? Because I don’t expect anything from anyone; expectations always hurt. Life is short. So love your life. Be happy. And keep smiling.", date: Date.init()), ChatMessage(name: "James Harden", message: "States that every individual has rights, simply by virtue of his or her existence. Other people have a duty to not infringe upon those rights.", date: Date.init(timeInterval: 203, since: Date.init())), ChatMessage(name: "Alex Anderson", message: "The right to life and the right to the maximum possible individual liberty and human dignity are fundamental: all other rights flow from them.", date: Date.init(timeInterval: 239, since: Date.init())), ChatMessage(name: "Patrick Malon", message: "Computers receiving data that is not intended for then, simply ignore the communication. So …… how do computers ", date: Date.init(timeInterval: -23823, since: Date.init())), ChatMessage(name: "Emile Sandé", message: "nothing important just saying Hi!", date: Date.init(timeInterval: -392, since: Date.init())), ChatMessage(name: "Brittery Spears", message: "hey, just wondering what you doing for the night", date: Date.init()),]
