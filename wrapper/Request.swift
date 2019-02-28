//
//  Request.swift
//  API WRAPPER
//
//  Created by user150359 on 1/23/19.
//  Copyright © 2019 user150359. All rights reserved.
//

import Foundation

class Request : NSObject
{
    func HTTPPostJSON(url: String,  data: Data,
                      callback: @escaping (String, String?) -> Void) {
        
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "POST"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        HTTPsendRequest(request: request, callback: callback)
    }
    
    func HTTPGETJSONAPI(url: String,  token: String,
                      callback: @escaping (String, String?) -> Void) {
        
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "GET"
        request.addValue("application/vnd.api+json",forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        
        HTTPsendRequest(request: request, callback: callback)
    }
    
    func HTTPDELETEJSONAPI(url: String,  token: String,
                        callback: @escaping (String, String?) -> Void) {
        
        var request = URLRequest(url: URL(string: url)!)
        
        request.httpMethod = "DELETE"
        request.addValue("application/vnd.api+json",forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        
        
        HTTPsendRequest(request: request, callback: callback)
    }
    
    
    func HTTPsendRequest(request: URLRequest,
                         callback: @escaping (String, String?) -> Void) {
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if (error != nil) {
                   
                    callback("", error?.localizedDescription)
                } else {
                    let outputStr  = String(data: data!, encoding: String.Encoding.utf8) as String!
                    callback(outputStr!, nil)
                }
        }
        
        task.resume()
    }
    
}
