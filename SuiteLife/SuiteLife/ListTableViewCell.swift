//
//  ListTableViewCell.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/13/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import os.log

class ListTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    //MARK: Properties

    @IBOutlet weak var selectButton: UISwitch!

    @IBOutlet weak var nameLabel: UITextField!
    
    var item: Item?
    
    //MARK: The internet tells me this function is called reasonably first and often as you scroll around.
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.delegate = self // if you don't have this line, text fields don't get handled
    }
    
    
    //MARK: UITextFieldDelegate
       
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { // I don't think this ever gets called.
        print("WE WANT TO RETURN FROM THE TEXT FIELD")
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("BEGAN EDITING")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Save your data here. Maybe.
        //        self.saveItems()
        
        print("We're trying to return the text field.")
        
        // Edit the attributes.
        let name = nameLabel.text ?? ""
        let checked = selectButton.isOn
        let isListItem = true
        item = Item(name: name, checked: checked, isListItem: isListItem) // TODO: You're not actually doing anything with this item. Pass up? Somehow???
        addSingleItem(item!)
        
    }
    
    //MARK: NSCoding
    private func loadItems() -> [Item]? {
        print("Attempting to load saved list items.")
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.ListArchiveURL.path) as? [Item] // If it finds something, it will give you an array of items.
    }
    
    private func addSingleItem(_ item: Item) {
        print("Attempting to save a single item.")
        var savedArray = loadItems()
        
        // Add item to array
        if savedArray != nil {
            savedArray?.append(item)
        }
        else {
            savedArray = [item]
        }
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(savedArray, toFile: Item.ListArchiveURL.path)
        if isSuccessfulSave {
            os_log("List successfully updated.", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to update list.", log: OSLog.default, type: .error)
        }
    }
    

}
