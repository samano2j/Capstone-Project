//
//  Email.swift
//  API WRAPPER
//
//  Created by user150359 on 1/23/19.
//  Copyright © 2019 user150359. All rights reserved.
//

import Foundation


class Email
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
    
    //TO:DO - properly parse response JSON to determine success
    
    struct MoveAttributes : Codable
    {
        var message_ids : [String]
        
        init () {
            message_ids = []
        }
    }
    
    struct MoveData : Codable {
        var attributes: MoveAttributes
        
        init()
        {
            attributes = MoveAttributes()
        }
    }
    struct MoveResult : Codable {
        var data: MoveData
        init() {
            data = MoveData()
        }
    }
    
    func MoveMessages(from_folder : String, to_folder : String, message_ids : [String]) -> Bool
    {
        var success = false
        
        let sem = DispatchSemaphore(value: 0)
        var MoveResults = MoveResult()
        
        for message_id in message_ids {
            MoveResults.data.attributes.message_ids.append(message_id)
        }
        
        let jsonData = try! JSONEncoder().encode(MoveResults)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print(jsonString)
        req.HTTPPUTJSONAPI(url: URL + "/common/folders/" + from_folder + "/messages/move_to/" + to_folder, token: jwt!, data: jsonData) { (data, error) in
            
            if (error == nil)
            {
                
                success = true
                
            }
            
            sem.signal()
        }
        
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        return success
    }
    
    struct CreateFolderAttributes : Codable
    {
        var name : String
        var parent_folder_id : Int?
        
        init () {
            parent_folder_id = nil
            name = ""
        }
        
    }
    struct CreateFolderData : Codable
    {
        var type : String
        var attributes : CreateFolderAttributes
        init () {
            attributes = CreateFolderAttributes()
            type = "folders"
        }
        
    }
    struct CreateFolderResult : Codable
    {
        var data : CreateFolderData
        init () {
            data = CreateFolderData()
        }
    }
    
    func CreateFolder(folder_name : String, parent_folder_id : Int?) -> Folder.singleresult?
    {
        var newFolder = CreateFolderResult()
        var resultFolder : Folder.singleresult? = nil
        
        let sem = DispatchSemaphore(value: 0)
        
        newFolder.data.attributes.name = folder_name
        newFolder.data.attributes.parent_folder_id = parent_folder_id
        
        let jsonData = try! JSONEncoder().encode(newFolder)
        
    
        req.HTTPPOSTJSONAPI(url: URL + "/common/folders", token: jwt!, data: jsonData) { (data, error) in
            
            if (error == nil)
            {
                do
                {
                    
                    let json = try JSONDecoder().decode(Folder.singleresult.self, from: data.data(using: .utf8)!)
                    resultFolder = json
                    
                } catch {
                    //print(error.localizedDescription)
                }
                
            }
            sem.signal()
            
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        return resultFolder
    }
    
    func SaveDraft(recpt_ids : [String], body : String, subject : String, reply_to_id : String, urgent : Bool)
    {
        let sem = DispatchSemaphore(value: 0)
        var message = Message.ComposeResult()
        var recpts : [Message.ComposeRecptData] = []
        
        for recpt_id in recpt_ids {
            var new_recpt = Message.ComposeRecptData()
            new_recpt.id = recpt_id
            new_recpt.attributes.recipient_id = recpt_id
            recpts.append(new_recpt)
        }
        message.data.attributes.body = body
        message.data.attributes.subject = subject
        message.data.attributes.reply_to_id = reply_to_id
        message.data.attributes.urgent = urgent
        
        for recpt in recpts {
            message.relationships.message_recipients.data.append(recpt)
        }
        
        let jsonData = try! JSONEncoder().encode(message)
        
        req.HTTPPOSTJSONAPI(url: URL + "/common/draft", token: jwt!, data: jsonData) { (data, error) in
          
            
            sem.signal()
        }

        _ = sem.wait(timeout: DispatchTime.distantFuture)
    }
    
    func ComposeMessage(recpt_ids : [String], body : String, subject : String, reply_to_id : String, urgent : Bool) -> Message.ComposeResult? {
       
        
        let sem = DispatchSemaphore(value: 0)
        
        var recpts : [Message.ComposeRecptData] = []
        
        for recpt_id in recpt_ids {
            var new_recpt = Message.ComposeRecptData()
            new_recpt.id = recpt_id
            new_recpt.attributes.recipient_id = recpt_id
            recpts.append(new_recpt)
        }
        
        var r = Message.ComposeResult()
        
        var Msg : Message.ComposeResult? = nil
        
        r.data.attributes.body = body
        r.data.attributes.subject = subject
        r.data.attributes.reply_to_id = reply_to_id
        r.data.attributes.urgent = urgent
        
        
        for recpt in recpts {
            r.relationships.message_recipients.data.append(recpt)
        }
        
        let jsonData = try! JSONEncoder().encode(r)
        
        req.HTTPPOSTJSONAPI(url: URL + "/common/message", token: jwt!, data: jsonData) { (data, error) in
            
            if (error == nil)
            {
                Msg = r
                
            }
         
            sem.signal()
        }
        
      
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
        return Msg
        
    }
    
    
    func GetFolders() -> Folder.result? {
        var Folders : Folder.result? = nil
        
        let sem = DispatchSemaphore(value: 0)
        req.HTTPGETJSONAPI(url: URL + "/common/folders", token: jwt!) { (data, error ) in
            
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
        req.HTTPGETJSONAPI(url: URL + "/common/folders/" + folder_id + "/messages", token: jwt!) { (data, error) in
            if (error == nil)
            {
                do
                {
                    
                  print(data)
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
        req.HTTPGETJSONAPI(url: URL + "/common/folders/" + folder_id + "/messages/" + message_id, token: jwt!) { (data, error) in
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
    
    func GetBroadcasts() {
        let sem = DispatchSemaphore(value: 0)
        
        req.HTTPGETJSONAPI(url: URL + "/common/broadcasts", token: jwt!) { (data, error) in
            if (error == nil)
            {
               
            } else {
                print("Error -> \(String(describing: error))")
            }
            
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
        
    }
    
    

    func GetMatchings() -> Profile.MatchUserResult? {
        let sem = DispatchSemaphore(value: 0)
        var matches : Profile.MatchUserResult? = nil
    
        req.HTTPGETJSONAPI(url: URL + "/client/matchings", token: jwt!) { (data, error) in
            if (error == nil)
            {
                do
                {
                    
                    
                    let json = try JSONDecoder().decode(Profile.MatchUserResult.self, from: data.data(using: .utf8)!)
                    matches = json
                    
                    
                
                } catch {
                    print(error.localizedDescription)
                }
                
            } else {
                print("Error -> \(String(describing: error))")
            }
            
            sem.signal()
        }
        
        _ = sem.wait(timeout: DispatchTime.distantFuture)
    
        return matches
        
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
    
    func GetToInformation(Message: Message.SingleMessage.result) -> Array<sender_information> {
        var to_information = Array<sender_information>()
        var msg_ids : [Int] = []
        
        for msg_id in Message.data.relationships.to.data {
            msg_ids.append(msg_id.id)
            
        }
        
        for msg_id in msg_ids {
            for ppl in Message.included {
                if (ppl.id == msg_id)
                {
                    var to = sender_information()
                    
                    to.first_name = ppl.attributes.first_name
                    to.last_name = ppl.attributes.last_name
                    to.id = ppl.id
                    
                    to_information.append(to)
                }
            }
        }
        
        return to_information
    }
    
    func GetToInformation(messages : Message.result, msg_id : String) -> Array<sender_information>
    {
        var to_information = Array<sender_information>()
        var msg_ids : [Int] = []
        
        for msg in messages.data {
            if (msg.id == msg_id)
            {
                for msg_id in msg.relationships.to.data {
                    msg_ids.append(msg_id.id)
                }
            }
        }
        
        
        for msg_id in msg_ids {
            for ppl in messages.included {
                if (ppl.id == msg_id)
                {
                    var to = sender_information()
                    
                    to.first_name = ppl.attributes.first_name
                    to.last_name = ppl.attributes.last_name
                    to.id = ppl.id
                    
                    to_information.append(to)
                }
            }
        }
        
        return to_information
    }
    
    func GetSenderInformation(messages : Message.result, msg_id : String) -> sender_information? {
        var sender_id : Int? = nil
        var sender_info : sender_information? = nil
        var temp = sender_information()
        
        for msg in messages.data {
            if (msg.id == msg_id) {
                sender_id = msg.attributes.sender_id
            }
        }
        
        if (sender_id != nil) {
            for sender in messages.included {
                if (sender_id == sender.id) {
                    temp.first_name = sender.attributes.first_name
                    temp.last_name = sender.attributes.last_name
                    temp.id = sender.id
                    
                    sender_info = temp
                }
            }
        }
        
        
        
        return sender_info
    }
    
    func DeleteMessage(folder_id: String, message_id: String) -> Bool
    {
        var success = false
        
        let sem = DispatchSemaphore(value: 0)
        
        req.HTTPDELETEJSONAPI(url: URL + "/common/folders/" + folder_id + "/messages/" + message_id, token: jwt!) { (data, error) in
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
        
        req.HTTPDELETEJSONAPI(url: URL + "/common/folders/" + folder_id, token: jwt!) { (data, error) in
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
        var msg_id : String
    }
    
    func GetUnreadMessages(Messages : Message.result) -> Array<unread_message>
    {
        var unread_messages = Array<unread_message>()

        for Message in Messages.data
        {
            if (Message.attributes.read_at == nil)
            {
                
                var sentat = Message.attributes.sent_at == nil ? "" : (Message.attributes.sent_at)!
                
                unread_messages.append(unread_message(folder_id: Message.attributes.folder_id, folder_name: Message.attributes.folder_name, subject: Message.attributes.subject, body: Message.attributes.body, sender_id: Message.attributes.sender_id, urgent: Message.attributes.urgent, sysmsg: Message.attributes.sysmsg, sent_at: sentat, msg_id: Message.id))
            }
        }
        
        return unread_messages
    }
}
