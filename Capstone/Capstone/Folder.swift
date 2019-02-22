//
//  Folder.swift
//  API WRAPPER
//
//  Created by user150359 on 1/24/19.
//  Copyright © 2019 user150359. All rights reserved.
//

import Foundation

class Folder  {
    
    struct attributes : Decodable {
        var parent_folder_id : Int?
        var owner_id : Int
        var name : String
        var type_id : Int
        var message_count : Int
        var unread_count: Int
        var system_folder : Int
    }
    
    struct data : Decodable {
        var id : String
        var type : String
        var attributes : attributes
    }
    
    
    struct result : Decodable {
        var data : [data]
    }
    
}
