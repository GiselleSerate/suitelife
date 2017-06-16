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
    
    weak var controller: ListTableViewController?
    

    func attachNameLabel(_ name: inout String) {
        nameLabel.text = name
    }
    
    func attachSelectButton(_ selectState: inout Bool) {
        selectButton.isOn = selectState
    }
    
    
    //MARK: Run First
    
    //The internet tells me this function is called reasonably first and often as you scroll around. They lied about "often."
    override func layoutSubviews() {
        super.layoutSubviews()
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
            // Edit the attributes.
            let name = nameLabel.text ?? ""
            let checked = selectButton.isOn
            let isListItem = true
            item = Item(name: name, checked: checked, isListItem: isListItem)
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
                    editSingleItem(item!)
                }
            }
    }
    
    
    //MARK: Modifying The List
    
    private func addSingleItem(_ item: Item) {
        print(controller?.items)
        print("Attempting to save a single item.")
        controller?.items.append(item)
        controller?.deleteBlanks()
        controller?.items.append(Item(name: "", checked: false, isListItem: true))
        print("Reload this from \(controller?.items)")
        controller?.tableView.reloadData() // Reload table.
    }
    
    private func editSingleItem(_ item: Item) {
        print("Attempting to edit a single item.")
        for thing in (controller?.items)! {
            print("Iterating")
            if thing.name == storedText { // apparently comparing the item to itself isn't gonna fly. come back to this maybe but for now use the name as a unique identifier.
                print(thing.name)
                print(item.name)
                print("suddenly everything changes violently it changes")
                thing.name = item.name
                return // We're only going to change the first one of this instance. Stop already.
            }
            
        }
    }
    
    private func deleteSingleItem() {
        if let delInd = (controller?.items.index(where:{$0.name == self.storedText})) {
            controller?.items.remove(at: delInd)
        }
        controller?.tableView.reloadData() // Refresh thaaat. 
    }
    

}
