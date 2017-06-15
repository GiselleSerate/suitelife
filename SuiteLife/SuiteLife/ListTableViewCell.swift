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
    
    var storedText: String = ""
    
    var item: Item?
    
    //TODO: Maybe it's a useful function. but also i don't want this right now
    func textFieldDidChange(_ textField: UITextField) {
        //        print("someone EDITED the TEXT FIELD")
    }
    
    func attachNameLabel(_ name: inout String) {
        nameLabel.text = name
    }
    
    func attachSelectButton(_ selectState: inout Bool) {
        selectButton.isOn = selectState
    }
    
    //MARK: The internet tells me this function is called reasonably first and often as you scroll around.
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        nameLabel.delegate = self // if you don't have this line, text fields don't get handled
    }
    
    
    //MARK: UITextFieldDelegate
       
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        storedText = textField.text! // keep the old text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Save your data here. Maybe.
        //        self.saveItems()
        
        if nameLabel.text == "" { // delete this item from the thing and also for now just hide the cell. 
            //TODO: use flag? so you can have an empty last cell
            print("Trying to hide this cell.")
            self.isHidden = true // does this hide the cell or the text field I can't tell
        }
        else { // its legit we want a legit edit
            // Edit the attributes.
            let name = nameLabel.text ?? ""
            let checked = selectButton.isOn
            let isListItem = true
            item = Item(name: name, checked: checked, isListItem: isListItem)
            if storedText == "" { // it's the last one, you do want to add a new item.
                print("The user wants to add a new item to the list.")
                addSingleItem(item!)
            }
            else {
                print("what do we want EDIT BEHAVIOR when do we want it SOON (for item \(item))")
                editSingleItem(item!)
            }
        }
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
            os_log("List successfully added to.", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to add to list.", log: OSLog.default, type: .error)
        }
    }
    
    private func editSingleItem(_ item: Item) {
        print("Attempting to edit a single item.")
        var savedArray = loadItems()
        
        for savedItem in savedArray! {
            if savedItem.name == storedText {
                print("Resetting name of item.")
                savedItem.name = item.name // reset name of item.
            }
        }
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(savedArray, toFile: Item.ListArchiveURL.path)
        if isSuccessfulSave {
            os_log("List successfully edited.", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to edit list.", log: OSLog.default, type: .error)
        }
    }
    

}
