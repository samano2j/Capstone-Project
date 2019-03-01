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
    var messages: [PCMessage] = []
    var defaultFrame: CGRect!
    
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
        
        messagesTable.transform = CGAffineTransform(scaleX: 1, y: -1)
        defaultFrame = self.view.frame
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        messagesTable.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        messagesTable.dataSource = self

        chatManager = ChatManager(
            instanceLocator: "v1:us1:c8b9b762-7de0-4e17-b597-b452e7659fa4",
            tokenProvider: PCTokenProvider(url: "https://us1.pusherplatform.io/services/chatkit_token_provider/v1/c8b9b762-7de0-4e17-b597-b452e7659fa4/token"),
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

class MyChatManagerDelegate: PCChatManagerDelegate {}

extension ViewController: PCRoomDelegate {
    func onMessage(_ message: PCMessage) {
        print("\(message.sender.id) sent \(message.text)")
        messages.insert(message, at: 0)
        DispatchQueue.main.async {
            self.messagesTable.reloadData()
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
