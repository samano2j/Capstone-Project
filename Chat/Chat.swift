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
        return (self.currentUser)!.rooms
    }
    
    func GetJoinableRooms() -> [PCRoom] {
        
        let sem = DispatchSemaphore(value: 0)
        var PCrooms : [PCRoom] = []
        
        currentUser?.getJoinableRooms() { (rooms, error) in
            if (error == nil)
            {
                PCrooms = rooms!
            }
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        return PCrooms
    }
    
}
