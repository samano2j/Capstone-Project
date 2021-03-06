//
//  Profile.swift
//  API WRAPPER
//
//  Created by user150359 on 2/7/19.
//  Copyright © 2019 user150359. All rights reserved.
//
import Foundation

class Profile {
    struct attributes : Decodable {
        var login : String
        var first_name : String
        var last_name : String
        var email : String
        var staff : Bool
    }
    
    struct data : Decodable {
        var id : String
        var type : String
        var attributes : attributes
    }
    
    struct result : Decodable {
        var data : data
    }
    
    struct MatchUserAttributes : Decodable {
        var first_name : String
        var last_name : String
    }
    
    struct MatchUserData : Decodable {
        var id : String
        var type : String
        //var attributes : MatchUserAttributes
    }
    
    struct MatchUserIncluded : Decodable {
        var id : Int
        var type : String
        var attributes : MatchUserAttributes
    }
    
    struct MatchUserResult : Decodable {
        var data : [MatchUserData]
        var included : [MatchUserIncluded]
    }

}
