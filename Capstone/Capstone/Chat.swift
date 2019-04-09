
//
//  Chat.swift
//  Chat
//
//  Created by user149302 on 3/24/19.
//  Copyright © 2019 user149302. All rights reserved.
//
import Foundation
import PusherChatkit

class Chat {
    var chatManager : ChatManager? = nil
    var currentUser: PCCurrentUser? = nil
    var currentSubscribedRooms : [PCRoom] = []
    
    func GetUserId(username: String, password: String) -> String?
    {
        let sem = DispatchSemaphore(value : 0)
        let req = Request()
        
        
        var id : String? = nil
        
        
        
        
        req.HTTPGETJSONAPI(url: Constants.idProvider + "/" + username + "/" + password, token: "")
        { (d, error) in
            
            if (error == nil)
            {
                if ( d != "invalid credentials" )
                {
                    
                    id = d
                }
            }
            
            
            sem.signal()
        }
        
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return id
    }
    
    func Authenticate(username : String, password: String, delegate : PCChatManagerDelegate) -> PCCurrentUser?
    {
        let user_id = GetUserId(username: username, password: password)
        
        
        let sem = DispatchSemaphore(value: 0)
        
        if (user_id == nil)
        {
            return nil;
        }
        
        
        let tokenProvider = PCTokenProvider(
            url: "http://108.174.164.127:8080/public/auth",
            requestInjector: { req -> PCTokenProviderRequest in
                req.addQueryItems([URLQueryItem(name: "username", value: username),
                                   URLQueryItem(name: "password", value: password)])
                
                return req
                
        }
            
        )
        
        ChatManager.registerForRemoteNotifications()
        
        if (AppDelegate.publicDeviceToken != nil)
        {
            ChatManager.registerDeviceToken(AppDelegate.publicDeviceToken!)
            
        }
        
        chatManager = ChatManager(
            instanceLocator: Constants.instanceLocator,
            tokenProvider: tokenProvider,//PCTokenProvider(url: Constants.tokenProvider),
            userID: user_id!
        )
        
        
        
        if (chatManager == nil)
        {
            return nil
        }
        
        chatManager!.connect(delegate: delegate) { (user, error) in
            if (error == nil)
            {
                self.currentUser = user
                self.currentUser!.enablePushNotifications()
            }
            
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        return self.currentUser
    }

    func Authenticate(username : String, delegate : PCChatManagerDelegate) -> PCCurrentUser?
    {
        let sem = DispatchSemaphore(value: 0)
        
        chatManager = ChatManager(
            instanceLocator: Constants.instanceLocator,
            tokenProvider: PCTokenProvider(url: "https://us1.pusherplatform.io/services/chatkit_token_provider/v1/22f58ecc-7a16-4269-84a6-7d27e20eb88e/token"),
            userID: username
        )
        
        if (chatManager == nil) {
            return nil
        }
        
        chatManager!.connect(delegate: delegate) { (user, error) in
            if (error == nil) {
                self.currentUser = user
                self.currentUser?.enablePushNotifications()
                
//                ChatManager.registerForRemoteNotifications()
                
//                if (AppDelegate.publicDeviceToken != nil)
//                {
//                    ChatManager.registerDeviceToken(AppDelegate.publicDeviceToken!)
//                }
                
                print("Connected!!")
            }
  
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return self.currentUser
    }
    
    func GetCurrentRooms() -> [PCRoom] {
        return self.currentUser != nil ? (self.currentUser)!.rooms : []
    }
    
    func GetJoinableRooms() -> [PCRoom] {
        
        let sem = DispatchSemaphore(value: 0)
        var PCrooms : [PCRoom] = []
        
        if (currentUser == nil)
        {
            return PCrooms
        }
        
        (currentUser!).getJoinableRooms() { (rooms, error) in
            if (error == nil)
            {
                PCrooms = rooms!
            }
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        return PCrooms
    }
    
    func UnSubscribeFromCurrentRoom(room : PCRoom) {
        
        if let index = currentSubscribedRooms.index(of: room) {
            currentSubscribedRooms.remove(at: index)
        }
        room.unsubscribe()
    }
    
    func SubscribeToRoom(room_id : String, delegate: PCRoomDelegate, message_limit : Int) -> Bool
    {
        let sem = DispatchSemaphore(value: 0)
        var success = false
        
        
        if (self.currentUser == nil)
        {
            return success
        }
        
        
        (self.currentUser)!.subscribeToRoomMultipart(id: room_id, roomDelegate: delegate, messageLimit: message_limit) { (error) in
            
            if (error == nil) {
                
                for room in (self.currentUser)!.rooms
                {
                    if (room.id == room_id)
                    {
                        self.currentSubscribedRooms.append(room)
                        success = true
                        break
                    }
                }
                
            }
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return success
    }
    
    func SubscribeToRoom(room : PCRoom, delegate: PCRoomDelegate, message_limit : Int) -> Bool
    {
        let sem = DispatchSemaphore(value: 0)
        var success = false
        
        if (self.currentUser == nil)
        {
            return success
        }
        
        (self.currentUser)!.subscribeToRoomMultipart(room: room, roomDelegate: delegate, messageLimit: message_limit) { (error) in
            
            if (error == nil) {
                success = true
                self.currentSubscribedRooms.append(room)
            }
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return success
    }
    
    func createRoom(name: String) -> PCRoom? {
        let sem = DispatchSemaphore(value: 0)
        var pcroom: PCRoom? = nil
        
        if (self.currentUser == nil) {
            return nil
        }
        
        (self.currentUser)!.createRoom(name: name) { room, error in
            guard error == nil else {
                print("Error creating room: \(String(describing: error?.localizedDescription))")
                return
            }
            pcroom = room
            print("Created public room called \(String(describing: room?.name))")
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return pcroom
    }
    
    func createRoom(name: String, isPrivate: Bool) -> PCRoom? {
        let sem = DispatchSemaphore(value: 0)
        var pcroom: PCRoom? = nil
        
        if (self.currentUser == nil) {
            return nil
        }
        
        (self.currentUser)!.createRoom(name: name, isPrivate: isPrivate) { room, error in
            guard error == nil else {
                print("Error creating room: \(String(describing: error?.localizedDescription))")
                return
            }
            print("Created public room called \(String(describing: room?.name))")
            pcroom = room
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return pcroom
    }
    
    func createRoom(name: String, yourListOfUserIDs: [String]) -> PCRoom? {
        let sem = DispatchSemaphore(value: 0)
        var pcroom: PCRoom? = nil
        
        if (self.currentUser == nil) {
            return nil
        }
        
        (self.currentUser)!.createRoom(name: name, addUserIDs: yourListOfUserIDs) { room, error in
            guard error == nil else {
                print("Error creating room: \(String(describing: error?.localizedDescription))")
                return
            }
            pcroom = room!
            print("Created public room called \(String(describing: room?.name))")
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return pcroom
    }

    func sendSimpleMessage(roomID: String, text: String) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var sucess = false
        
        if (self.currentUser == nil) {
            return sucess
        }
        
        (self.currentUser)!.sendSimpleMessage(roomID: roomID, text: text) { message, error in
            guard error == nil else {
                print("Error sending message to \(String(describing: roomID)): \(String(describing: error?.localizedDescription))")
                return
            }
            print("Sent message to \(String(describing: roomID))")
            sucess = true
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return sucess
    }
    
    func FetchMessages(room : PCRoom, limit : Int) -> [PCMultipartMessage] {
        var messages : [PCMultipartMessage] = []
        let sem = DispatchSemaphore(value: 0)
        self.currentUser!.fetchMultipartMessages(room, limit: limit) { (msgs, error) in
            messages = (error == nil) ? msgs! : []
            sem.signal()
        }
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        return messages
    }
    
    func FetchMessages(room : PCRoom, initialID : String?) -> [PCMultipartMessage] {
        var msgs : [PCMultipartMessage] = []
        let sem = DispatchSemaphore(value: 0)
        (self.currentUser)!.fetchMultipartMessages(room, initialID: initialID) { messages, err in
            guard err == nil else {
                print("Error fetching messages from \(String(describing: room.name)): \(err!.localizedDescription)")
                return
            }
            msgs = (err == nil) ? messages! : []
            sem.signal()
        }
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        return msgs
    }
    
    func AddUser(anotherUser : PCUser, room : PCRoom) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var sucess = false
        
        (self.currentUser)!.addUser(anotherUser, to: room) { error in
            guard error == nil else {
                print("Error adding user to \(String(describing: room.name)): \(String(describing: error?.localizedDescription))")
                return
            }
            print("Added user \(String(describing: anotherUser.id)) to \(String(describing: room.name))")
            sucess = true
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return sucess
    }
    
    func AddUser(anotherUserID : String, room_id : String) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var sucess = false
        
        (self.currentUser)!.addUser(id: anotherUserID, to: room_id) { error in
            if error != nil {
                print("Error adding user to \(String(describing: room_id)): \(String(describing: error?.localizedDescription))")
            } else {
                print("Added user \(anotherUserID) from room ID: \(String(describing: room_id))")
                sucess = true
                sem.signal()
            }
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return sucess
    }
    
    func AddUser(usersToAddArray : [PCUser], room : PCRoom) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var sucess = false
        
        (self.currentUser)!.addUsers(usersToAddArray, to: room) { error in
            guard error == nil else {
                print("Error adding users to \(String(describing: room.name)): \(String(describing: error?.localizedDescription))")
                return
            }
            let userIDs = usersToAddArray.map { $0.id }.joined(separator: ", ")
            print("Added users \(String(describing: userIDs)) to \(String(describing: room.name))")
            sucess = true
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return sucess
    }
    
    func AddUser(usersIDsToAddArray : [String], room_id : String) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var sucess = false
        
        (self.currentUser)!.addUsers(ids: usersIDsToAddArray, to: room_id) { error in
            guard error == nil else {
                print("Error adding users to \(String(describing: room_id)): \(String(describing: error?.localizedDescription))")
                return
            }
            let userIDs = usersIDsToAddArray.joined(separator: ", ")
            print("Added users \(String(describing: userIDs)) to room ID: \(String(describing: room_id))")
            sucess = true
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return sucess
    }
    
    func RemoveUser(anotherUser : PCUser, room : PCRoom) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var sucess = false
        
        (self.currentUser)!.removeUser(anotherUser, from: room) { error in
            guard error == nil else {
                print("Error removing user from \(String(describing: room.name)): \(String(describing: error?.localizedDescription))")
                return
            }
            print("Removed user \(String(describing: anotherUser.id)) from \(String(describing: room.name))")
            sucess = true
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return sucess
    }
    
    func RemoveUser(anotherUserID : String, room_id : String) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var sucess = false
        
        (self.currentUser)!.removeUser(id: anotherUserID, from: room_id) { error in
            guard error == nil else {
                print("Error removing user from \(String(describing: room_id)): \(String(describing: error?.localizedDescription))")
                return
            }
            print("Removed user \(String(describing: anotherUserID)) from room ID: \(String(describing: room_id))")
            sucess = true
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return sucess
    }
    
    func RemoveUser(usersToRemoveArray : [PCUser], room : PCRoom) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var sucess = false
        
        (self.currentUser)!.removeUsers(usersToRemoveArray, from: room) { error in
            guard error == nil else {
                print("Error removing users from \(String(describing: room.name)): \(String(describing: error?.localizedDescription))")
                return
            }
            let userIDs = usersToRemoveArray.map { $0.id }.joined(separator: ", ")
            print("Removed users \(String(describing: userIDs)) from \(String(describing: room.name))")
            sucess = true
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return sucess
    }
    
    func RemoveUser(userIDsToRemoveArray : [String], room_id : String) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var sucess = false
        
        (self.currentUser)!.removeUsers(ids: userIDsToRemoveArray, from: room_id) { error in
            guard error == nil else {
                print("Error removing users from \(String(describing: room_id)): \(String(describing: error?.localizedDescription))")
                return
            }
            let userIDs = userIDsToRemoveArray.joined(separator: ", ")
            print("Removed users \(String(describing: userIDs)) from room ID: \(String(describing: room_id))")
            sucess = true
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return sucess
    }
    
    func LeaveRoom(room : PCRoom) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var sucess = false
        
        (self.currentUser)!.leaveRoom(room) {error in
            guard error == nil else {
                print("Error leaving room \(String(describing: room.name)): \(String(describing: error?.localizedDescription))")
                return
            }
            print("Left room \(String(describing: room.name))")
            sucess = true
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return sucess
    }
    
    func LeaveRoom(room_id : String) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var sucess = false
        
        (self.currentUser)!.leaveRoom(id: room_id) { error in
            guard error == nil else {
                print("Error leaving room with ID \(String(describing: room_id)): \(String(describing: error?.localizedDescription))")
                return
            }
            print("Left room with ID \(String(describing: room_id))")
            sucess = true
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return sucess
    }
    
    func DeleteRoom(room : PCRoom) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var sucess = false
        
        (self.currentUser)!.deleteRoom(room) { error in
            guard error == nil else {
                print("Error deleting room \(String(describing: room.name)):\(String(describing: error?.localizedDescription))")
                return
            }
            print("Deleted room \(String(describing: room.name))")
            sucess = true
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return sucess
    }
    
    func DeleteRoom(room_id : String) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var sucess = false
        
        (self.currentUser)!.deleteRoom(id: room_id) { error in
            guard error == nil else {
                print("Error deleting room \(String(describing: room_id)):\(String(describing: error?.localizedDescription))")
                return
            }
            print("Deleted room \(String(describing: room_id))")
            sucess = true
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return sucess
    }
}
