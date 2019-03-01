//
//  Email.swift
//  API WRAPPER
//
//  Created by user150359 on 1/23/19.
//  Copyright © 2019 user150359. All rights reserved.
//
import Foundation


class eHealth
{
    var URL = ""
    var req = Request()
    var jwt: String? = nil
    
    init(url: String) {
        URL = url
    }
    
    func Auth(User: String, Password: String) -> Bool {
        let json: [String: Any] = ["auth": ["login": User, "password": Password]]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        let sem = DispatchSemaphore(value: 0)
        
        req.HTTPPostJSON(url: URL + "/user_token", data: jsonData!) { (data, error) in
            if (error == nil)
            {
                
                do
                {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: data.data(using: .utf8)!) as! [String:Any]
                    let token = parsedData["jwt"] as! String
                    
                    self.jwt = token
                    
                    
                } catch {
                    print("Error deserializing JWT token -> \(data)")
                    
                }
                
            }
            else
            {
                print("Error -> \(String(describing: error))")
            }
            
            
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        return !(jwt ?? "").isEmpty
    }
    
    
    
    func GetFolders() -> Folder.result? {
        var Folders : Folder.result? = nil
        
        let sem = DispatchSemaphore(value: 0)
        req.HTTPGETJSONAPI(url: URL + "/staff/folders", token: jwt!) { (data, error ) in
            
            if (error == nil)
            {
                do
                {
                    
                    let json = try JSONDecoder().decode(Folder.result.self, from: data.data(using: .utf8)!)
                    Folders = json
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
            else
            {
                print("Error -> \(String(describing: error))")
                
            }
            
            sem.signal()
            
        }
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        return Folders
    }
    
    func GetMessages(folder_id : String) -> Message.result? {
        var Messages : Message.result? = nil
        
        let sem = DispatchSemaphore(value: 0)
        req.HTTPGETJSONAPI(url: URL + "/staff/folders/" + folder_id + "/messages", token: jwt!) { (data, error) in
            if (error == nil)
            {
                do
                {
                    
                    let json = try JSONDecoder().decode(Message.result.self, from: data.data(using: .utf8)!)
                    Messages = json
                    
                    
                    
                } catch {
                    print(error.localizedDescription)
                }
                
            }
            else
            {
                print("Error -> \(String(describing: error))")
                
            }
            
            sem.signal()
            
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        return Messages
        
    }
    
    func GetMessage(folder_id : String, message_id : String) -> Message.SingleMessage.result? {
        var msg : Message.SingleMessage.result? = nil
        
        let sem = DispatchSemaphore(value: 0)
        req.HTTPGETJSONAPI(url: URL + "/staff/folders/" + folder_id + "/messages/" + message_id, token: jwt!) { (data, error) in
            if (error == nil)
            {
                do
                {
                    
                    
                    
                    let json = try JSONDecoder().decode(Message.SingleMessage.result.self, from: data.data(using: .utf8)!)
                    msg = json
                    
                    
                    
                    
                    
                } catch {
                    print(error.localizedDescription)
                }
                
            }
            else
            {
                print("Error -> \(String(describing: error))")
                
            }
            
            sem.signal()
            
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        return msg
    }
    
    
    struct sender_information {
        var first_name : String?
        var last_name : String?
        var id : Int?
        
        init () {
            first_name = nil
            last_name = nil
            id = nil
        }
    }
    
    struct profile_information {
        var first_name : String?
        var last_name : String?
        var id : String?
        
        init () {
            first_name = nil
            last_name = nil
            id = nil
        }
    }
    func GetProfile() -> profile_information {
        var profile = profile_information()
        var profile_data : Profile.result? = nil
        
        let sem = DispatchSemaphore(value: 0)
        
        req.HTTPGETJSONAPI(url: URL + "/common/profile", token: jwt!) { (data, error) in
            if (error == nil)
            {
                do
                {   let json = try JSONDecoder().decode(Profile.result.self, from: data.data(using: .utf8)!)
                    profile_data = json
                    
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                print("Error -> \(String(describing: error))")
            }
            
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        if (profile_data != nil)
        {
            profile.first_name = (profile_data?.data.attributes.first_name)!
            profile.last_name = (profile_data?.data.attributes.last_name)!
            profile.id = (profile_data?.data.id)!
        }
        
        
        
        return profile
    }
    
    func GetSenderInformation(Message : Message.SingleMessage.result) -> sender_information? {
        let sender_id = Message.data.attributes.sender_id
        var sender_info : sender_information? = nil
        var temp = sender_information()
        
        for sender in Message.included
        {
            if (sender.id == sender_id)
            {
                temp.first_name = sender.attributes.first_name
                temp.last_name = sender.attributes.last_name
                temp.id = sender.id
                
                sender_info = temp
                
                break
            }
        }
        
        return sender_info
    }
    
    
    func DeleteMessage(folder_id: String, message_id: String) -> Bool
    {
        var success = false
        
        let sem = DispatchSemaphore(value: 0)
        
        req.HTTPDELETEJSONAPI(url: URL + "/staff/folders/" + folder_id + "/messages/" + message_id, token: jwt!) { (data, error) in
            if (error == nil)
            {
                
                success = true
            } else {
                print("Error -> \(String(describing: error))")
            }
            
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        
        
        
        return success
        
    }
    
    func DeleteFolder(folder_id : String) -> Bool
    {
        var success = false
        
        let sem = DispatchSemaphore(value: 0)
        
        req.HTTPDELETEJSONAPI(url: URL + "/staff/folders/" + folder_id, token: jwt!) { (data, error) in
            if (error == nil)
            {
                
                success = true
            } else {
                print("Error -> \(String(describing: error))")
            }
            
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        
        
        
        return success
        
    }
    
    
    func IsRead(Message : Message.SingleMessage.result) -> Bool
    {
        return !(Message.data.attributes.read_at == nil)
    }
    
    struct unread_message
    {
        var folder_id : Int
        var folder_name : String
        var subject : String
        var body : String
        var sender_id : Int
        var urgent : Bool
        var sysmsg : Bool
        var sent_at : String
    }
    
    func GetUnreadMessages(Messages : Message.result) -> Array<unread_message>
    {
        
        var unread_messages = Array<unread_message>()
        
        for Message in Messages.data
        {
            if (Message.attributes.read_at == nil)
            {
                unread_messages.append(unread_message(folder_id: Message.attributes.folder_id, folder_name: Message.attributes.folder_name, subject: Message.attributes.subject, body: Message.attributes.body, sender_id: Message.attributes.sender_id, urgent: Message.attributes.urgent, sysmsg: Message.attributes.sysmsg, sent_at: Message.attributes.sent_at))
            }
        }
        
        return unread_messages
    }
}
