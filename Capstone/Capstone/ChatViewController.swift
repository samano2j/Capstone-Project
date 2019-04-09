//
//  ChatViewController.swift
//  Capstone
//
//  Created by Christian John on 2019-02-22.
//  Copyright © 2019 Christian John. All rights reserved.
//

/*
 MIT License
 
 Copyright (c) 2017-2018 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import MessageKit
import MessageInputBar
import PusherChatkit
import SafariServices

/// A base class for the example controllers
class ChatViewController: MessagesViewController, MessagesDataSource, PCRoomDelegate {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    static var messageList: [MockMessage] = []
    var chat: Chat? = nil
    var room: PCRoom? = nil
    var subscribed: Int?
    var index: Int?
    var roomTitle: String?
//    var chatDelegate: PCRoomDelegate?
    
    var chatManagerDelegate: PCChatManagerDelegate?
    var chatRoomDelegate: PCRoomDelegate?
    var typingUsers : [String] = []
    var roomMessages: [PCMultipartMessage] = []
    
    let messageKitCurrentUser = Sender(id: (ChatMainViewController.chat.currentUser?.id)!, displayName: (ChatMainViewController.chat.currentUser?.name)!)
    
    let refreshControl = UIRefreshControl()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.chatDelegate = MyChatDelegate()
        
        configureMessageCollectionView()
        configureMessageInputBar()
        ChatViewController.messageList.removeAll(keepingCapacity: true)
        subscriptionChoice()
        loadFirstMessages()
        
        switch subscribed {
        case 0:
            roomTitle = ChatMainViewController.ChatSubscribedRooms[index!].name
        case 1:
            roomTitle = ChatMainViewController.ChatUnsubscribedRooms[index!].name
        default:
            break
        }
        self.navigationItem.setTitle(roomTitle ?? "", subtitle: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func subscriptionChoice() {
        if (ChatMainViewController.chat.currentUser?.rooms.index(where: { $0.id == self.room!.id }) == nil) {
                let ac = UIAlertController(title: "Join Room", message: "Do you want to join \(self.room!.name)?", preferredStyle: .alert)
                let closure: (UIAlertAction) -> Void = { _ in
                    let _ = ChatMainViewController.chat.SubscribeToRoom(room: self.room!, delegate: self, message_limit: 0)
                    if let index = ChatMainViewController.ChatUnsubscribedRooms.index(where: { $0.name == self.room!.name }) {
                        ChatMainViewController.ChatSubscribedRooms.append(ChatMainViewController.ChatUnsubscribedRooms[index])
                        ChatMainViewController.ChatUnsubscribedRooms.remove(at: index)
                    }
                    self.navigationController?.popToViewController(self.navigationController!.viewControllers[1] as! ChatMainViewController, animated: true) }
                let yes = UIAlertAction(title: "Yes", style: .default, handler: closure)
                let no = UIAlertAction(title: "No", style: .cancel) { _ in _ = self.navigationController?.popToViewController(self.navigationController!.viewControllers[1] as! ChatMainViewController, animated: true) }
                ac.addAction(yes)
                ac.addAction(no)
                self.present(ac, animated: true, completion: nil)
            }
    }
    
    func loadFirstMessages() {
        DispatchQueue.global(qos: .userInitiated).async {
            let _ = ChatMainViewController.chat.SubscribeToRoom(room: self.room!, delegate: self, message_limit: 0)
            self.roomMessages = ChatMainViewController.chat.FetchMessages(room: self.room!, limit: 20) //oldestMessageIDReceived
            var messages: [MockMessage] = []
            for msg in self.roomMessages {
                let sender = Sender(id: msg.sender.id, displayName: msg.sender.displayName)
                for part in msg.parts {
                    switch part.payload {
                    case .inline(let p):
                        messages.append(MockMessage(text: p.content, sender: sender, messageId: String(msg.id), date: msg.createdAtDate))
                    case .url(let url):
                        messages.append(MockMessage(text: url.url, sender: sender, messageId: String(msg.id), date: msg.createdAtDate))
                    case .attachment(let attach):
                        messages.append(MockMessage(custom: attach.customData, sender: sender, messageId: String(msg.id), date: msg.createdAtDate))
                    }
                }
            }
            DispatchQueue.main.async {
                ChatViewController.messageList = messages
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
        }
    }
    
    @objc
    func loadMoreMessages() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
            self.getMessages(count: 20) { messages in
                DispatchQueue.main.async {
                    ChatViewController.messageList.insert(contentsOf: messages, at: 0)
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    func getMessages(count: Int, completion: ([MockMessage]) -> Void) {
        var messages: [MockMessage] = []
        var oldestMessageIDReceived = ""
        if let older = self.roomMessages.first {
            oldestMessageIDReceived = String(older.id)
        }
        let msgs = ChatMainViewController.chat.FetchMessages(room: self.room!, initialID: oldestMessageIDReceived)
        self.roomMessages.insert(contentsOf: msgs, at: 0)
        for msg in msgs {
            let sender = Sender(id: msg.sender.id, displayName: msg.sender.displayName)
            for part in msg.parts {
                switch part.payload {
                case .inline(let p):
                    messages.append(MockMessage(text: p.content, sender: sender, messageId: String(msg.id), date: msg.createdAtDate))
                case .url(let url):
                    messages.append(MockMessage(text: url.url, sender: sender, messageId: String(msg.id), date: msg.createdAtDate))
                case .attachment(let attach):
                    messages.append(MockMessage(custom: attach.customData, sender: sender, messageId: String(msg.id), date: msg.createdAtDate))
                }
            }
        }
        completion(messages)
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        messageInputBar.sendButton.tintColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: MockMessage) {
        // Reload last section to update header/footer labels and insert a new one
        DispatchQueue.main.async {
            ChatViewController.messageList.append(message)
            self.messagesCollectionView.performBatchUpdates({
                self.messagesCollectionView.insertSections([ChatViewController.messageList.count - 1])
                if ChatViewController.messageList.count >= 2 {
                    self.messagesCollectionView.reloadSections([ChatViewController.messageList.count - 2])
                }
            }, completion: { [weak self] _ in
                if self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToBottom(animated: true)
                }
            })
        }
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !ChatViewController.messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: ChatViewController.messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    // MARK: - MessagesDataSource
    
    func currentSender() -> Sender {
        return messageKitCurrentUser
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return ChatViewController.messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return ChatViewController.messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    
    // PCRoomDelegate
    func onMultipartMessage(_ message: PCMultipartMessage) {
        let sender = Sender(id: message.sender.id, displayName: message.sender.displayName)
        var note = ""
        if (message.room.users.count > 2) {
            note.append(message.sender.displayName + ": ")
        }
        
        for part in message.parts {
            switch part.payload {
            case .inline(let payload):
                let msg = MockMessage(text: payload.content, sender: sender, messageId: String(message.id), date: message.createdAtDate)
                insertMessage(msg)
                
                note.append(payload.content)
                let preview = ChatMessage(name: self.room!.name, message: note, date: message.createdAtDate, room: self.room!)
                
                let index = ChatMainViewController.ChatSubscribedRooms.index(where: { $0.name == self.room!.name })
                ChatMainViewController.ChatSubscribedRooms[index!] = preview
                
                
                print("Received message with text: \(payload.content) from \(message.sender.debugDescription)")
            case .url(let payload):
                print("Received message with url: \(payload.url) of type \(payload.type) from \(message.sender.debugDescription)")
                var img: UIImage? = nil
                guard let url = URL(string: payload.url) else { return }
                UIImage.loadFrom(url: url) { image in
                    img = image!
                }
                let msg = MockMessage(image: img!, sender: sender, messageId: String(message.id), date: message.createdAtDate)
                insertMessage(msg)
            case .attachment(let payload):
                payload.url() { downloadUrl, error in
                }
            }
        }
    }
    
    func onUserStartedTyping(user: PCUser) {
        print("User \(String(describing: user.name)) started typing in room \(self.room.debugDescription)")
        var appendedString = ""
        if (self.room?.users.count == 2) {
            appendedString = user.displayName + " is typing..."
        }
        
        DispatchQueue.main.async {
            if (ChatMainViewController.chat.currentUser?.id != user.id) {
                self.navigationItem.setTitle(self.roomTitle ?? "", subtitle: appendedString)
            }
        }
    }
    
    func onUserStoppedTyping(user: PCUser) {
        print("User \(user.displayName)) stopped typing in room \(self.room.debugDescription)")
        
        DispatchQueue.main.async {
            self.navigationItem.setTitle(self.roomTitle ?? "", subtitle: "")
        }
    }
    
    func onUserJoined(user: PCUser) {
        print("User \(user.displayName) just joined the room \(self.room.debugDescription)")
        let appendedString = user.displayName + " just joined the room"
                
        DispatchQueue.main.async {
            self.navigationItem.setTitle(self.roomTitle ?? "", subtitle: appendedString)
        }
    }
    
    func onUserLeft(user: PCUser) {
        print("User \(user.displayName) just left the room \(self.room.debugDescription)")
        let appendedString = user.displayName + " just left the room"
        
        DispatchQueue.main.async {
            self.navigationItem.setTitle(self.roomTitle ?? "", subtitle: appendedString)
        }
    }
    
    func onPresenceChanged(stateChange: PCPresenceStateChange, user: PCUser) {
        print("User \(user.displayName) just went \(self.room.debugDescription)")
        
        let appendedString = user.displayName + " is " + stateChange.current.rawValue
        
        DispatchQueue.main.async {
            self.navigationItem.setTitle(self.roomTitle ?? "", subtitle: appendedString)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "showRoomDetails" {
                if let seguedToMVC = segue.destination as? RoomDetailTableViewController {
                    seguedToMVC.room = self.room!
                }
            }
        }
    }
}

// MARK: - MessageCellDelegate

extension ChatViewController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
}

// MARK: - MessageLabelDelegate

extension ChatViewController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
        guard let number = URL(string: "tel://" + phoneNumber) else { return }
        UIApplication.shared.open(number)
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
        openURL(url)
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
    func openURL(_ url: URL) {
        let webViewController = SFSafariViewController(url: url)
        if #available(iOS 10.0, *) {
            webViewController.preferredControlTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            webViewController.preferredBarTintColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
            webViewController.configuration.accessibilityNavigationStyle = .combined
        }
        present(webViewController, animated: true, completion: nil)
    }
}

// MARK: - MessageInputBarDelegate

extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            
            if let str = component as? String {
                let _ = ChatMainViewController.chat.sendSimpleMessage(roomID: (self.room?.id)!, text: str)
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom(animated: true)
    }
        
    func messageInputBar(_ inputBar: MessageInputBar, textViewTextDidChangeTo text: String) {
        ChatMainViewController.chat.currentUser?.typing(in: self.room!)  { (Error) in
            if (Error != nil) {
                print("Chat Error: \(String(describing: Error))")
            }
        }
    }
}

//class MyChatDelegate: PCRoomDelegate {}
//
//class Instance
//{
//    static let sem = DispatchSemaphore(value: 1)
//    static var instance : PCRoomClass? = nil
//
//    static func GetInstance() {
//        sem.wait(timeout: DispatchTime.distantFuture)
//        if (instance == nil)
//        {
//            instance = PCRoomClass()
//        }
//        _ = sem.signal()
//
//        return instance
//    }
//}
//
//class PCRoomClass : PCRoomDelegate {
//
////    func onMultipartMessage(_ message: PCMultipartMessage)
////    {
//
//    }
//}
