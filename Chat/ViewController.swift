//
//  ViewController.swift
//  Chat
//
//  Created by user149302 on 2/28/19.
//  Copyright © 2019 user149302. All rights reserved.
//

import UIKit
import PusherChatkit

class ViewController: UIViewController {
    var chatManager: ChatManager!
    var currentUser: PCCurrentUser?
    var chatManagerDelegate: PCChatManagerDelegate?
    var chatRoomDelegate: PCRoomDelegate?
    var messages: [PCMessage] = []
    var defaultFrame: CGRect!
    var currentRoom: PCRoom?
    var typingUsers : [String] = []
    
    @IBOutlet weak var messageInput: UITextField!
    @IBOutlet weak var messagesTable: UITableView!
    
    func moveViewsWithKeyboard(height: CGFloat) {
        self.view.frame = defaultFrame.offsetBy(dx: 0, dy: height)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let frame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        moveViewsWithKeyboard(height: -frame.height)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        moveViewsWithKeyboard(height: 0)
    }
    



    
    @IBAction func TextViewChanged(_ sender: Any) {
        
        
        if (currentRoom != nil){
            currentUser?.typing(in: currentRoom!) { (Error) in
                
                if (Error != nil)
                {
                    print("Chat Error: \(String(describing: Error))")
                }
                
            }
        }
        
    }
    

    @IBAction func SendMessage(_ sender: UIButton) {
      
        self.currentUser!.sendMessage(
            roomID: self.currentUser!.rooms.first!.id,
            text: self.messageInput.text!
        ) { messageId, error in
            guard error == nil else {
                print("Error sending message: \(error!.localizedDescription)")
                return
            }
            print("Message sent!")
        }
        
        self.messageInput.text!.removeAll()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Chat"
        messagesTable.transform = CGAffineTransform(scaleX: 1, y: -1)
        defaultFrame = self.view.frame
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        messagesTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        messagesTable.dataSource = self

        chatManager = ChatManager(
            instanceLocator: "v1:us1:22f58ecc-7a16-4269-84a6-7d27e20eb88e",
            tokenProvider: PCTokenProvider(url: "https://us1.pusherplatform.io/services/chatkit_token_provider/v1/22f58ecc-7a16-4269-84a6-7d27e20eb88e/token"),
            userID: "iden"
        )
        
        self.chatManagerDelegate = MyChatManagerDelegate()
        
        chatManager.connect(
            delegate: self.chatManagerDelegate!
        ) { [unowned self] currentUser, error in
            guard error == nil else {
                print("Error connecting: \(error!.localizedDescription)")
                return
            }
            print("Connected!")
            
            guard let currentUser = currentUser else { return }
            
            
            self.currentUser = currentUser
            self.currentRoom = currentUser.rooms[0]
            
           
            currentUser.subscribeToRoom(
                room: currentUser.rooms[0],
                roomDelegate: self
            ) { err in
                guard error == nil else {
                    print("Error subscribing to room: \(error!.localizedDescription)")
                    return
                }
                print("Subscribed to room!")
                
                
            }
            
            
            
        }
        
        
        
    }
    
   
}

class MyChatManagerDelegate: PCChatManagerDelegate {
    

}

extension ViewController: PCRoomDelegate {
    func onMessage(_ message: PCMessage) {
        print("\(message.sender.id) sent \(message.text)")
        messages.insert(message, at: 0)
        DispatchQueue.main.async {
            self.messagesTable.reloadData()
        }
    }
    
    func onUserStartedTyping(user: PCUser) {
        print("User \((user.name)!) started typing in room \((currentRoom?.name)!)")
        var appendedString = ""
        
        typingUsers.append((user.name)!)
        
        for user in typingUsers {
            appendedString += user + ", "
        }
        
        appendedString += " is typing..."
        
        DispatchQueue.main.async {
            self.navigationItem.title = appendedString
        }

    }

    func onUserStoppedTyping(user: PCUser) {
         print("User \((user.name)!) stopped typing in room \((currentRoom?.name)!)")
        var appendedString = ""
        
        typingUsers = typingUsers.filter{ $0 != (user.name)! }
        
        if (typingUsers.count == 0 )
        {
            appendedString = "Chat"
        }
        else
        {
            for user in typingUsers {
                appendedString += user + ", "
            }
        
            appendedString += " is typing..."
        }
        
        DispatchQueue.main.async {
            self.navigationItem.title = appendedString
        }

    }
    
    
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        let message = self.messages[indexPath.row]
        cell.textLabel?.text = "\(message.sender.displayName): \(message.text)"
        return cell
    }
}
