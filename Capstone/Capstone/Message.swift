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
    
    struct meta : Decodable {
        var per_page : Int
        var current_page : Int
        var next_page : Int?
        var prev_page : Int?
        var total_pages : Int
        var total_count : Int
    }
    
    struct name_attributes : Decodable {
        var first_name : String
        var last_name : String
    }
    
    struct included : Decodable {
        var id : Int
        var type : String
        var attributes : name_attributes
    }
    
    struct result : Decodable {
        var data : [data]
        var meta : meta
        var included : [included]
    }
    
    
    struct SingleMessage {
        
        struct meta : Decodable {
            
        }
        struct result : Decodable {
            var data : data
            var meta : SingleMessage.meta
            var included : [included]
        }
        
    }
    
}
