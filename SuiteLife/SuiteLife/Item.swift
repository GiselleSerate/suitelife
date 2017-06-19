//
//  Item.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/13/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import os.log

class Item: NSObject, NSCoding {
    
    //MARK: Properties
    var name: String
    var checked: Bool
    var price: Float
    
    override public var description: String {
        return "Item Name: \(name), Checked: \(checked), Price: \(price)"
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ListArchiveURL = DocumentsDirectory.appendingPathComponent("list")
    static let PantryArchiveURL = DocumentsDirectory.appendingPathComponent("pantry")
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let checked = "checked"
        static let price = "price"
    }
    
    //MARK: Initialization
    init(name: String, checked: Bool, price: Float) {
        self.name = name
        self.checked = checked
        self.price = price
    }
    
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(checked, forKey: PropertyKey.checked)
        aCoder.encode(price, forKey: PropertyKey.price)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String
            else {
                os_log("Heyy, we are unable to decode the name for this Item.", log: OSLog.default, type: .debug)
                return nil
        }
        let checked = aDecoder.decodeBool(forKey: PropertyKey.checked)
        let price = aDecoder.decodeFloat(forKey: PropertyKey.price)
        
        self.init(name: name, checked: checked, price: price)
    }
}
