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
    
    
    func Authenticate(username : String, delegate : PCChatManagerDelegate) -> PCCurrentUser?
    {
         let sem = DispatchSemaphore(value: 0)

        chatManager = ChatManager(
            instanceLocator: Constants.instanceLocator,
            tokenProvider: PCTokenProvider(url: Constants.tokenProvider),
            userID: username
        )
        
        if (chatManager == nil)
        {
            return nil
        }
        
        chatManager!.connect(delegate: delegate) { (user, error) in
            if (error == nil)
            {
                self.currentUser = user
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
    
    func FetchMessages(room : PCRoom, limit : Int) -> [PCMultipartMessage] {
        var messages : [PCMultipartMessage] = []
        let sem = DispatchSemaphore(value: 0)
        self.currentUser!.fetchMultipartMessages(room, limit: limit) { (msgs, error) in
            
            if (error == nil)
            {
                messages = msgs!
            }

            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        return messages
    }
}
