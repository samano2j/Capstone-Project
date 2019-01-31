//
//  Message.swift
//  API WRAPPER
//
//  Created by user150359 on 1/24/19.
//  Copyright © 2019 user150359. All rights reserved.
//

import Foundation


class Message {
    
    struct attributes : Decodable {
        var folder_id : Int
        var folder_name : String
        var subject : String
        var body : String
        var sender_id : Int
        var urgent : Bool
        var sysmsg : Bool
        var sent_at : String
        var read_at : String?
    }
    
    struct data : Decodable {
        var id : String
        var type : String
        var attributes : attributes
    }
    
    
    struct result : Decodable {
        var data : [data]
    }
    
    
    struct SingleMessage {
        
        struct result : Decodable {
            var data : data
        }
        
    }
    
}
