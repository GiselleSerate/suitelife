//
//  User.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/23/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import Foundation

class User: NSObject {
    
    //MARK: Properties
    var name: String
    var handle: String
    var userID: String
    
    override var description: String {
        return "User \(userID) with name: \(name), handle: \(handle)"
    }
    
    init(name: String, handle: String, userID: String) {
        self.name = name
        self.handle = handle
        self.userID = userID
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? User {
            return self.userID == object.userID
        }
        else {
            return false
        }
    }
    
}
