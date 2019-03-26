//
//  ChatExtra.swift
//  Capstone
//
//  Created by Joe  Samano on 2019-03-26.
//  Copyright © 2019 Christian John. All rights reserved.
//

import Foundation
import PusherChatkit

class ChatExtra {
    var chatManager : ChatManager? = nil
    var currentUser: PCCurrentUser? = nil
    var currentSubscribedRooms : [PCRoom] = []

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
            guard error == nil else {
                print("Error adding user to \(String(describing: room_id)): \(String(describing: error?.localizedDescription))")
                return
            }
            print("Added user \(anotherUserID) from room ID: \(String(describing: room_id))")
            sucess = true
            sem.signal()
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
