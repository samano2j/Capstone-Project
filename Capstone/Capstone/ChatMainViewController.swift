//
//  ChatMainViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-03-18.
//  Copyright © 2019 Christian John. All rights reserved.
//

import UIKit
import PusherChatkit

class ChatMainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PCChatManagerDelegate {
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
//    var cars = ["BMW", "Range Rover", "Tesla", "Lamborghini", "Datsun", "Jeep", "Lada", "Spyker", "Roewe", "Audi", "Toyota", "Chrysler", "Ford", "McLaren Senna", "Aston Martin Vanquish", "Triumph Spitfire", "Volkswagen Beetle", "Studebaker Power Hawk", "Lamborghini Murciélago", "Plymouth Road Runner Superbird", "Studebaker Power Hawk", "Lamborghini Murciélago", "AMC Gremlin", "Plymouth Road Runner Superbird", "Bentley Mulsanne", "Ford Thunderbird", "Chervolet", "Lagonda", "Bentley", "Dodge", "Donkervoort", "Freightliner", "Hyundai", "General Motors", "Hindustan Motors", "Mitsubishi","Pierce-Arrow", "Prodrive", "Studebaker"]
//    var friuts = ["Pear", "Apple", "Pineapple", "Oranges", "WaterMelon", "Cherry", "Strawberry", "Pomangranate", "Plum", "Rasberry", "Lemon", "Grapefruit", "Coconut", "Avocodo", "Nectarine", "Mango", "Kiwi", "Papaya", "Carambola(U.K) – starfruit (U.S)", "Blueberry","Pear", "Apricot", "Kiwano (horned melon)", "Pomelo", "White currant", "Eggplant", "Cucumber", "Tangerine", "Nance", "Fig", "Durian", "Elderberry", "Japanese plum", "Passionfruit", "Plantain", "Blackcurrant", "Dragonfruit (or Pitaya)", "Buddha's hand (fingered citron)", "Purple mangosteen", "White sapote"]
    
    var ChatSubscribedRooms: [ChatMessage] = []
    var ChatUnsubscribedRooms: [ChatMessage] = []
    var chat = Chat()
    
    struct SegmentedControl {
        static let subscribed = 0
        static let unsubscribed = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Rooms"
        
        if let _ = chat.Authenticate(username: "christian", delegate: self) {
            initializeSubscibed()
            initializeUnsubscibed()
        }
        
        // Do any additional setup after loading the view.
    }
    
    func getCustomImage(imageDisplayName: String?, imageView: UIImageView!){
        if let name = imageDisplayName, !name.isEmpty {
            imageView.setImage(string:name, color: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), circular: true, stroke: false)
        } else {
            imageView.setImage(string:"Display Picture", color: UIColor.colorHash(name: "Display Picture"), circular: true, stroke: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentControl.selectedSegmentIndex {
        case SegmentedControl.subscribed:
            return ChatSubscribedRooms.count
        case SegmentedControl.unsubscribed:
            return ChatUnsubscribedRooms.count
        default:
            break
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCellIdentifier", for: indexPath) as! ChatKitMessagesListCell
        switch segmentControl.selectedSegmentIndex {
        case SegmentedControl.subscribed:
            cell.senderName.text = ChatSubscribedRooms[indexPath.row].name
            cell.resentMessage.text = ChatSubscribedRooms[indexPath.row].message
            cell.messagesDate.text = ChatSubscribedRooms[indexPath.row].relativeChatDateString
            getCustomImage(imageDisplayName: ChatSubscribedRooms[indexPath.row].name, imageView: cell.messageAvatar)
        case SegmentedControl.unsubscribed:
            cell.senderName.text = ChatUnsubscribedRooms[indexPath.row].name
            cell.resentMessage.text = ChatUnsubscribedRooms[indexPath.row].message
            cell.messagesDate.text = ChatUnsubscribedRooms[indexPath.row].relativeChatDateString
            getCustomImage(imageDisplayName: ChatUnsubscribedRooms[indexPath.row].name, imageView: cell.messageAvatar)
        default:
            break
        }
        return cell
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            switch identifier {
            case "segueIdentifierForChat":
                if let cell = sender as? ChatKitMessagesListCell,
                    let indexPath = tableView.indexPath(for: cell),
                    let seguedToMVC = segue.destination as? ChatViewController {
                    seguedToMVC.chat = chat
                    switch segmentControl.selectedSegmentIndex {
                    case SegmentedControl.subscribed:
                        seguedToMVC.room = ChatUnsubscribedRooms[indexPath.row].room
                    case SegmentedControl.unsubscribed:
                        seguedToMVC.room = ChatUnsubscribedRooms[indexPath.row].room
                    default:
                        break
                    }
                }
            default: break
            }
        }

    }

    
    func initializeSubscibed() {
        var first_message = ""
        var name = ""
        var date: Date = Date.init()
        for room in chat.GetCurrentRooms() {
            name = room.name
            let msgs = chat.FetchMessages(room: room, limit: 1)
            for msg in msgs {
                first_message.append(msg.sender.displayName + ": ")
                date = msg.createdAtDate
                for part in msg.parts {
                    switch part.payload {
                    case .inline(let p):
                        print(p.content)
                        first_message.append(p.content)
                    case .url(_):
                        print("url")
                    case .attachment(_):
                        print("attachment")
                    }
                }
            }
            ChatSubscribedRooms.append(ChatMessage(name: name, message: first_message, date: date, room: room))
        }
    }
    
    func initializeUnsubscibed() {
        var first_message = ""
        var date: Date = Date.init()
        for room in chat.GetJoinableRooms() {
            let msgs = chat.FetchMessages(room: room, limit: 1)
            for msg in msgs {
                first_message.append(msg.sender.displayName + ": ")
                date = msg.createdAtDate
                for part in msg.parts {
                    switch part.payload {
                    case .inline(let p):
                        print(p.content)
                        first_message.append(p.content)
                    case .url(_):
                        print("url")
                    case .attachment(_):
                        print("attachment")
                    }
                }
            }
            ChatUnsubscribedRooms.append(ChatMessage(name: room.name, message: first_message, date: date, room: room))
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

