//
//  ListTableViewCell.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/13/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import os.log
import M13Checkbox

class ListTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    //MARK: Properties

    @IBOutlet weak var selectButton: UISwitch!
    @IBOutlet weak var checkbox: M13Checkbox!
    @IBOutlet weak var nameLabel: UITextField!
    
    var storedText: String = ""
    
    var item: Item?
    
    weak var controller: ListTableViewController?
    

    func attachNameLabel(_ name: inout String) {
        nameLabel.text = name
    }
    
    func attachSelectButton(_ selectState: inout Bool) { // This also runs on reload. 
        selectButton.isOn = selectState
        if selectState {
            checkbox.setCheckState(.checked, animated: false)
        }
        else {
            checkbox.setCheckState(.unchecked, animated: false)
        }
    }
    
    
    //MARK: Run First
    
    //The internet tells me this function is called reasonably first and often as you scroll around. They lied about "often."
    override func layoutSubviews() {

        super.layoutSubviews()
        
        nameLabel.delegate = self // if you don't have this line, text fields don't get handled
        
        // Setting what value gets returned if the checkbox is checked or not.
        checkbox.checkedValue = true
        checkbox.uncheckedValue = false
    }
    
    
    //MARK: Checkbox Handling
    
    @IBAction func checkListener(_ sender: Any) {
        print("TOGGLING CHECK")
        if nameLabel.text != "" { // Only try to toggle the check if it is a real item.
            editSingleItem(Item(name: nameLabel.text!, checked: true, isListItem: true), toggleCheck: true)
        }
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
        // Edit the attributes.
        let name = nameLabel.text ?? ""
        print("This is what's going on with the checkbox: \(checkbox.value)")
        let checked = checkbox.value!
//        let checked = selectButton.isOn
        let isListItem = true
        item = Item(name: name, checked: checked as! Bool, isListItem: isListItem)
        if storedText == "" { // This cell is the last one, you want to add a new item.
            print("The user wants to add a new item to the list.")
            addSingleItem(item!)
        }
        else {
            print("what do we want EDIT BEHAVIOR when do we want it SOON (for item \(String(describing: item)))")
            if name == "" { // Delete this item.
                deleteSingleItem()
            }
            else { // Edit item.
                editSingleItem(item!, toggleCheck: false)
            }
        }
    }
    
    
    //MARK: Modifying The List
    
    private func addSingleItem(_ item: Item) {
        print("Attempting to save a single item.")
        controller?.items.append(item)
        controller?.deleteBlanks()
        controller?.items.append(Item(name: "", checked: false, isListItem: true)) // Add to array.
        controller?.tableView.reloadData() // Refresh the table.
    }
    
    private func editSingleItem(_ item: Item, toggleCheck: Bool) {
        print("Attempting to edit a single item.")
        
        var compareMe = storedText
        if toggleCheck {
            compareMe = item.name
        }
        
        for thing in (controller?.items)! {
            print("\(storedText), matches \(thing.name)")
            if thing.name == compareMe { // apparently comparing the item to itself isn't gonna fly. come back to this maybe but for now use the name as a unique identifier.
                print(thing.name)
                print(item.name)
                print("suddenly everything changes violently it changes")
                thing.name = item.name
                if toggleCheck {
                    print("Also I toggled a check.")
                    thing.checked = !thing.checked
                }
                else {
                    print("I don't think I should toggle this check.")
                }
                return // We're only going to change the first one of this instance. Stop already.
            }
            
        }
        print("Finished edit attempt.")
    }
    
    private func deleteSingleItem() {
        if let delInd = (controller?.items.index(where:{$0.name == self.storedText})) {
            controller?.items.remove(at: delInd)
        }
        controller?.tableView.reloadData() // Refresh the table.
    }
    

}
