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

    @IBOutlet weak var checkbox: M13Checkbox!
    @IBOutlet weak var nameLabel: UITextField!
    
    var storedText: String = ""
    
    var item: Item?
    
    weak var controller: ListTableViewController?
    

    func attachItem(_ newItem: inout Item) {
        
        item = newItem
        
        // Set name label.
        nameLabel.text = item?.name
        
        // Set checked state.
        if (item?.checked)! {
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
        
        nameLabel.delegate = self // If you don't have this line, text fields don't get handled.
        
        // Setting what value gets returned if the checkbox is checked or not.
        checkbox.checkedValue = true
        checkbox.uncheckedValue = false
    }
    
    
    //MARK: Checkbox Handling
    
    @IBAction func checkListener(_ sender: Any) { // Reset whether items thinks the box is checked or not.
        item?.checked = checkbox.value! as! Bool
    }
    
    
    //MARK: UITextFieldDelegate
       
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        storedText = textField.text! // Keep the old text in this variable.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

        
        // Edit the attributes in the array.
        item?.name = nameLabel.text ?? ""
        item?.checked = checkbox.value! as! Bool
        
        if storedText == "" { // This cell is the last one, you want to replace the blank line.
            controller?.items.append(Item(name: "", checked: false, isListItem: true))
            controller?.tableView.reloadData()
        }
        else {
            if item?.name == "" { // Delete this item, because you have made its text blank.
                controller?.items.remove(at: (controller?.items.index(of: item!))!) // Delete item.
                controller?.tableView.reloadData() // Refresh the table.
            }
        }
    }
}
