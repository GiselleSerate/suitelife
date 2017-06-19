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
    var isListItem: Bool // if it's on the list, it's true, if it's in the pantry it's false
    
    override public var description: String {
        return "Item Name: \(name), Checked: \(checked), Price: \(price)"
    }
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ListArchiveURL = DocumentsDirectory.appendingPathComponent("list")
    static let PantryArchiveURL = DocumentsDirectory.appendingPathComponent("pantry")
    // Store both list and pantry in the same place.
//    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("inventory")
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let checked = "checked"
        static let price = "price"
        static let isListItem = "isListItem"
    }
    
    //MARK: Initialization
    init(name: String, checked: Bool, price: Float, isListItem: Bool) {
        self.name = name
        self.checked = checked
        self.price = price
        self.isListItem = isListItem
    }
    
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(checked, forKey: PropertyKey.checked)
        aCoder.encode(price, forKey: PropertyKey.price)
        aCoder.encode(isListItem, forKey: PropertyKey.isListItem)
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
        let isListItem = aDecoder.decodeBool(forKey: PropertyKey.isListItem)
        
        self.init(name: name, checked: checked, price: price, isListItem: isListItem)
    }
}
