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
    var chatManagerDelegate: PCChatManagerDelegate?
    var chatRoomDelegate: PCRoomDelegate?
    var typingUsers : [String] = []
    
    let messageKitCurrentUser = Sender(id: (ChatMainViewController.chat.currentUser?.id)!, displayName: (ChatMainViewController.chat.currentUser?.name)!)
    
    let refreshControl = UIRefreshControl()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureMessageCollectionView()
        configureMessageInputBar()

//        self.chatManagerDelegate = MyChatManagerDelegate()
//        self.chatRoomDelegate = MyChatRoomDelegate()
        
        loadFirstMessages()
        self.navigationItem.setTitle("MessageKit", subtitle: "")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func loadFirstMessages() {
        DispatchQueue.global(qos: .userInitiated).async {
            let _ = ChatMainViewController.chat.SubscribeToRoom(room: self.room!, delegate: self, message_limit: 0)
            let msgs = ChatMainViewController.chat.FetchMessages(room: self.room!, limit: 100)
            var messages: [MockMessage] = []
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
            SampleData.shared.getMessages(count: 20) { messages in
                DispatchQueue.main.async {
                    ChatViewController.messageList.insert(contentsOf: messages, at: 0)
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                }
            }
        }
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
//        let name = message.sender.displayName
//        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
//        let dateString = formatter.string(from: message.sentDate)
//        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    // PCRoomDelegate
    func onMultipartMessage(_ message: PCMultipartMessage) {
        let sender = Sender(id: message.sender.id, displayName: message.sender.displayName)
        
        for part in message.parts {
            switch part.payload {
            case .inline(let payload):
                let receivedMessage = MockMessage(text: payload.content, sender: sender, messageId: String(message.id), date: message.createdAtDate)
                insertMessage(receivedMessage)
                print("Received message with text: \(payload.content) from \(message.sender.debugDescription)")
            case .url(let payload):
                print("Received message with url: \(payload.url) of type \(payload.type) from \(message.sender.debugDescription)")
            case .attachment(let payload):
                payload.url() { downloadUrl, error in
                    // do something with the download url
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
                self.navigationItem.setTitle("MessageKit", subtitle: appendedString)
            }
        }
    }
    
    func onUserStoppedTyping(user: PCUser) {
        print("User \(user.displayName)) stopped typing in room \(self.room.debugDescription)")
        
        DispatchQueue.main.async {
            self.navigationItem.setTitle("MessageKit", subtitle: "")
        }
    }
    
    func onUserJoined(user: PCUser) {
        print("User \(user.displayName) just joined the room \(self.room.debugDescription)")
        let appendedString = user.displayName + "just joined the room"
        
        DispatchQueue.main.async {
            self.navigationItem.setTitle("MessageKit", subtitle: appendedString)
        }
    }
    
    func onUserLeft(user: PCUser) {
        print("User \(user.displayName) just left the room \(self.room.debugDescription)")
        let appendedString = user.displayName + "just left the room"
        
        DispatchQueue.main.async {
            self.navigationItem.setTitle("MessageKit", subtitle: appendedString)
        }
    }
    
//    func onPresenceChanged(stateChange: PCPresenceStateChange, user: PCUser) {
//    }
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
//            else if let img = component as? UIImage {
//                let message = MockMessage(image: img, sender: currentSender(), messageId: UUID().uuidString, date: Date())
//                insertMessage(message)
//            }
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
