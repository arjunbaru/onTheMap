//
//  studentClient.swift
//  onTheMap
//
//  Created by Arjun Baru on 02/10/16.
//  Copyright © 2016 Arjun Baru. All rights reserved.
//

import Foundation
import UIKit

extension udacityClient {
    struct Constants{
        static let UdacityBaseURL: String = "https://www.udacity.com/api/"
    }
    
    //MARK: -- Methods
    struct Methods{
        static let Session = "session"
        static let Users = "users/"
    }
    
    //MARK: -- JSON Body Keys
    struct JSONBodyKeys {
        static let Username = "username"
        static let Password = "password"
        static let Udacity = "udacity"
    }
    
    //MARK: -- JSON Response Keys
    struct JSONResponseKeys {
        
        //MARK: -- Account
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
        static let app_json = "application/json"
        
        //MARK: -- Session
        static let Session = "session"
        static let ID = "id"
        static let Expiration = "expiration"
        
        //MARK: -- User Data
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        
        
    }
    
}
