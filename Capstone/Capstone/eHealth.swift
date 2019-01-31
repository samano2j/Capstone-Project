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
}
