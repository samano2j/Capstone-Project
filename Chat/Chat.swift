//
//  Chat.swift
//  Chat
//
//  Created by user149302 on 3/24/19.
//  Copyright © 2019 user149302. All rights reserved.
//

import Foundation
import PusherChatkit
import PusherChatkit.Swift
import PusherPlatform

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
    func LeaveRoom(room : PCRoom) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var success = false
        self.currentUser!.leaveRoom(room) { (error) in
            if (error == nil)
            {
                success = true
            }
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return success
    }
    
    func DeleteRoom(room : PCRoom) -> Bool {
        let sem = DispatchSemaphore(value: 0)
        var success = false
        self.currentUser!.deleteRoom(room) { (error) in
            if (error == nil)
            {
                success = true
            }
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return success
        
    }
    func CreateRoom(name : String, isPrivate: Bool) -> PCRoom?
    {
        var new_room : PCRoom? = nil
        let sem = DispatchSemaphore(value: 0)

        self.currentUser!.createRoom(name: name, isPrivate: isPrivate) { (room, error) in
            
            if (error == nil) {
                new_room = room
            }
            sem.signal()
        }
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        return new_room
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
    
    func UnSubscribeFromRoom(room : PCRoom) {
        
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
        var new_limit = message_limit
        if (new_limit > 100)
        {
            new_limit = 100
        }
        (self.currentUser)!.subscribeToRoomMultipart(room: room, roomDelegate: delegate, messageLimit: new_limit) { (error) in
            
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
        
        var new_limit = limit
        
        if (limit > 100)
        {
            new_limit = 100
        }
        
        self.currentUser!.fetchMultipartMessages(room, limit: new_limit) { (msgs, error) in
            
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
