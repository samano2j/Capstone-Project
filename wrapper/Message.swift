
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
    
        struct ComposeAttributes : Codable {
            var body : String
            var subject : String
            var urgent : Bool
            var reply_to_id : String
            
            init () {
                body = ""
                subject = ""
                urgent = false
                reply_to_id = ""
                
            }
        }
        
        struct ComposeRecptDataAttributes : Codable
        {
            var bcc : Bool
            var recipient_id : String
            
            
            init () {
                recipient_id = ""
                bcc = false
            }
            
        }
        struct ComposeRecptData : Codable
        {
            var id : String
            var type : String
            var attributes : ComposeRecptDataAttributes
            
            init () {
                id = ""
                type = "message_recipients"
                attributes = ComposeRecptDataAttributes()
            }
            
            
        }
        struct ComposeRecpt : Codable
        {
            var data : [ComposeRecptData]
            
            init() {
                data = []
                
            }
            
        }
        struct ComposeRelationships : Codable {
            var message_recipients : ComposeRecpt
            
            init () {
                message_recipients = ComposeRecpt()
            }
            
        }
        
        struct ComposeData : Codable
        {
            var type : String
            var attributes : ComposeAttributes
            
            init () {
                type = "messages"
                attributes = ComposeAttributes()
            }
        }
        
        struct ComposeResult : Codable {
            var data : ComposeData
            var relationships : ComposeRelationships
            
            init () {
                data = ComposeData()
                relationships = ComposeRelationships()
                
            }
            
        }
    
    
}
