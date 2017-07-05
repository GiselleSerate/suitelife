//
//  Group.swift
//  SuiteLife
//
//  Created by cssummer17 on 7/5/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import Foundation

class Group: NSObject {
    
    var groupID: String
    var name: String
    
    init(groupID: String, name: String) {
        self.groupID = groupID
        self.name = name
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? Group {
            return self.groupID == object.groupID
        }
        else {
            return false
        }
    }
    
}
