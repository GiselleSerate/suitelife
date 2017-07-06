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
    var price: Int
    
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
    init(name: String, checked: Bool, price: Int) {
        self.name = name
        self.checked = checked
        self.price = price
    }
    
    init(fromDictionary dict: NSDictionary) {
        guard let dictionary = dict as? [String: Any] else {
                fatalError("Failed to cast dict to Dictionary.")
        }
        self.name = dictionary[PropertyKey.name] as! String
        self.checked = dictionary[PropertyKey.checked] as! Bool
        self.price = dictionary[PropertyKey.price] as! Int
    }
    
    //MARK: Firebase
    func toDict() -> NSDictionary {
        let dict = [PropertyKey.name: self.name as NSString, PropertyKey.checked: self.checked as NSNumber, PropertyKey.price: self.price as NSNumber]
        return dict as NSDictionary
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
                os_log("Unable to decode the name for this Item.", log: OSLog.default, type: .debug)
                return nil
        }
        let checked = aDecoder.decodeBool(forKey: PropertyKey.checked)
        let price = aDecoder.decodeInt32(forKey: PropertyKey.price) // TODO: Figure out whether I should worry about Int32 vs Int64 or just whatever. I'm casting anyway.
        
        self.init(name: name, checked: checked, price: Int(price))
    }
}
