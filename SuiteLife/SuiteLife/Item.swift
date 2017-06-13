//
//  Item.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/13/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import os.log

class Item {
    
    //MARK: Properties
    var name: String
    var checked: Bool
    
    public var description: String {
        return "Item Name: \(name), Checked: \(checked)"
    }
    
    
    //MARK: Initialization
    init?(name: String, checked: Bool) {
        guard !name.isEmpty
            else {
                return nil
        }
        self.name = name
        self.checked = checked
    }
    
}
