//
//  ChatMainViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-03-18.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit
import PusherChatkit
import SwipeCellKit
import PusherChatkit
import SparrowKit
import SPStorkController

class ChatMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PCChatManagerDelegate {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    static var ChatSubscribedRooms: [ChatMessage] = []
    static var ChatUnsubscribedRooms: [ChatMessage] = []
    
    static var chat = Chat()
    
    struct SegmentedControl {
        static let subscribed = 0
        static let unsubscribed = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.segmentControl.selectedSegmentIndex = 0
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        definesPresentationContext = true
        
        tableView.allowsSelection = true
        
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "Rooms"
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createRoom))
        self.navigationItem.rightBarButtonItem = add
        
        if (ChatMainViewController.ChatSubscribedRooms.isEmpty && ChatMainViewController.ChatUnsubscribedRooms.isEmpty) {
            spinner.startAnimating()
        }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            let _ = ChatMainViewController.chat.Authenticate(username: "christian", delegate: self!)
//            let _ = ChatMainViewController.chat.Authenticate(username: LoginViewController.username, password: LoginViewController.password, delegate: self!)
            let joined = self?.initialize(rooms: ChatMainViewController.chat.GetCurrentRooms())
            let available = self?.initialize(rooms: ChatMainViewController.chat.GetJoinableRooms())
            
            DispatchQueue.main.async {
                if (ChatMainViewController.ChatSubscribedRooms.isEmpty && ChatMainViewController.ChatUnsubscribedRooms.isEmpty) {
                    ChatMainViewController.ChatSubscribedRooms = joined ?? []
                    ChatMainViewController.ChatUnsubscribedRooms = available ?? []
                }
                self?.tableView.reloadData()
                self?.spinner?.stopAnimating()
            }
        }
    }
    
    func getCustomImage(imageDisplayName: String?, imageView: UIImageView!){
        if let name = imageDisplayName, !name.isEmpty {
            imageView.setImage(string:name, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), circular: true, stroke: false)
        } else {
            imageView.setImage(string:"Display Picture", color: UIColor.colorHash(name: "Display Picture"), circular: true, stroke: false)
        }
    }
    
    @objc
    func createRoom() {
        let ac = UIAlertController(title: "Create Room", message: "Enter the name of the room", preferredStyle: .alert)
        ac.addTextField()

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let submitAction = UIAlertAction(title: "Create", style: .default) { [unowned ac] _ in
            guard let answer = ac.textFields![0].text else { return }
            guard let room = ChatMainViewController.chat.createRoom(name: answer) else {
                let ac = UIAlertController(title: "Error", message: "Sorry you cannot complete this action", preferredStyle: .alert)
                self.present(ac, animated: true, completion: nil)
                return
            }
            let preview = room.createdByUserID + " named the group " + room.name
            ChatMainViewController.ChatSubscribedRooms.append(ChatMessage(name: room.name, message: preview, date: room.createdAtDate, room: room))
            self.tableView.reloadData()
        }

        ac.addAction(submitAction)
        ac.addAction(cancelAction)
        present(ac, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentControl.selectedSegmentIndex {
        case SegmentedControl.subscribed:
            return ChatMainViewController.ChatSubscribedRooms.count
        case SegmentedControl.unsubscribed:
            return ChatMainViewController.ChatUnsubscribedRooms.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCellIdentifier", for: indexPath) as! ChatKitMessagesListCell
        
        switch segmentControl.selectedSegmentIndex {
        case SegmentedControl.subscribed:
            cell.senderName.text = ChatMainViewController.ChatSubscribedRooms[indexPath.row].name
            cell.resentMessage.text = ChatMainViewController.ChatSubscribedRooms[indexPath.row].message
            cell.messagesDate.text = ChatMainViewController.ChatSubscribedRooms[indexPath.row].relativeChatDateString
            getCustomImage(imageDisplayName: ChatMainViewController.ChatSubscribedRooms[indexPath.row].name, imageView: cell.messageAvatar)
        case SegmentedControl.unsubscribed:
            cell.senderName.text = ChatMainViewController.ChatUnsubscribedRooms[indexPath.row].name
            cell.resentMessage.text = ChatMainViewController.ChatUnsubscribedRooms[indexPath.row].message
            cell.messagesDate.text = ChatMainViewController.ChatUnsubscribedRooms[indexPath.row].relativeChatDateString
            getCustomImage(imageDisplayName: ChatMainViewController.ChatUnsubscribedRooms[indexPath.row].name, imageView: cell.messageAvatar)
        default:
            break
        }
        return cell
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch segmentControl.selectedSegmentIndex {
        case SegmentedControl.subscribed:
            if (ChatMainViewController.chat.DeleteRoom(room: ChatMainViewController.ChatSubscribedRooms[indexPath.row].room)) {
                ChatMainViewController.ChatSubscribedRooms.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case SegmentedControl.unsubscribed:
            if (ChatMainViewController.chat.DeleteRoom(room: ChatMainViewController.ChatUnsubscribedRooms[indexPath.row].room)) {
                ChatMainViewController.ChatUnsubscribedRooms.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        default:
            break
        }
    }
//    // MARK: - Navigation
    func initialize(rooms: [PCRoom]) -> [ChatMessage] {
        var first_message = ""
        var date = Date()
        var messages: [ChatMessage] = []
        for room in rooms {
            let msgs = ChatMainViewController.chat.FetchMessages(room: room, limit: 1)
            for msg in msgs {
                if (room.users.count > 2) {
                    first_message.append(msg.sender.displayName + ": ")
                }
                date = msg.createdAtDate
                
                for part in msg.parts {
                    switch part.payload {
                    case .inline(let p):
                        first_message.append(p.content)
                    case .url(let p):
                        first_message.append(p.url)
                    case .attachment(_):
                        first_message.append("\(msg.sender.displayName) sent an attachment")
                    }
                }
            }
            if (msgs.count == 0) {
                first_message = room.createdByUserID + " named the group " + room.name
                date = room.createdAtDate
            }
            messages.append(ChatMessage(name: room.name, message: first_message, date: date, room: room))
            first_message = ""
        }
        return messages
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "segueIdentifierForChat":
                if let cell = sender as? ChatKitMessagesListCell,
                    let indexPath = tableView.indexPath(for: cell),
                    let seguedToMVC = segue.destination as? ChatViewController {
                    switch segmentControl.selectedSegmentIndex {
                    case SegmentedControl.subscribed:
                        seguedToMVC.room = ChatMainViewController.ChatSubscribedRooms[indexPath.row].room
                        seguedToMVC.subscribed = 0
                        seguedToMVC.index = indexPath.row
                    case SegmentedControl.unsubscribed:
                        seguedToMVC.room = ChatMainViewController.ChatUnsubscribedRooms[indexPath.row].room
                        seguedToMVC.subscribed = 1
                        seguedToMVC.index = indexPath.row
                    default:
                        break
                    }
                }
            default: break
            }
        }
    }
    
    func onRemovedFromRoom(_ room: PCRoom) {
        DispatchQueue.main.async {
            guard let index = ChatMainViewController.ChatSubscribedRooms.index(where: { $0.name == room.name }) else { return }
            ChatMainViewController.ChatSubscribedRooms.remove(at: index)
            self.tableView.reloadData()
        }
    }
}


public class ChatKitMessagesListCell: UITableViewCell {
    @IBOutlet weak var messageAvatar: UIImageView!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var resentMessage: UILabel!
    @IBOutlet weak var messagesDate: UILabel!
    
}

class ChatMessage: NSObject {
    let name: String
    let message: String
    let date: Date
    let room: PCRoom
    
    init(name: String, message: String, date: Date, room: PCRoom) {
        self.name = name
        self.message = message
        self.date = date
        self.room = room
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

