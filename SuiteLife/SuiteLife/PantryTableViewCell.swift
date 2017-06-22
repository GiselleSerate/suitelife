//
//  PantryTableViewCell.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/13/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import os.log
import M13Checkbox

class PantryTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    let itemPantryInstance = PantryDataModel.sharedInstance
    
    //MARK: Properties
    
    @IBOutlet weak var checkbox: M13Checkbox!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var priceLabel: UITextField!
    
    var storedText: String = ""
    
    var item: Item?
    
    weak var controller: PantryTableViewController?
    
    func attachItem(_ newItem: inout Item) {
        
        item = newItem
        if item == itemPantryInstance.items.last { // Hide last item.
            self.isHidden = true
            nameLabel.text = "Should Be Hidden" // TODO: Remove this line once you're convinced this is working.
        }
        else { // Set and don't hide other items.
            
            
            // Set name label.
            nameLabel.text = item?.name
            
            // Set checked state.
            if (item?.checked)! {
                checkbox.setCheckState(.checked, animated: false)
            }
            else {
                checkbox.setCheckState(.unchecked, animated: false)
            }
            
            // Set price label.
            priceLabel.text = String(describing: item!.price)
            
            nameLabel.tag = 0
            priceLabel.tag = 1
        }
    }
    
    
    //MARK: Run First
    
    //The internet tells me this function is called reasonably first and often as you scroll around. They lied about "often."
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        nameLabel.delegate = self // If you don't have this line, text fields don't get handled.
        priceLabel.delegate = self
        
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
        if textField.tag == 0 { // If it's a name
            storedText = textField.text! // Keep the old text in this variable.
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Edit the attributes in the array.
        item?.name = nameLabel.text ?? ""
        item?.checked = checkbox.value! as! Bool
        item?.price = Int(String(priceLabel.text!.characters.remove(at: priceLabel.text!.characters.index(of: ".")!))) ?? 0
        
        if textField === nameLabel { // Did you just finish editing the name label?
            
            if item?.name == "" && storedText == "" { // You took this text and it was blank and now it's blank again. Don't do anything.
                
            }
            else if storedText == "" { // This cell is the last one, you want to replace the blank line.
                itemPantryInstance.items.append(Item(name: "", checked: false, price: 0))
                controller?.refreshPage()
            }
            else { // Delete this item, because you have made its text blank.
                itemPantryInstance.items.remove(at: (itemPantryInstance.items.index(of: item!))!) // Delete item.
                controller?.refreshPage() // Refresh the table.
            }
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Limit the price field's allowable characters to be a decimal.
        if textField.tag == 1 {
            let inverseSet = NSCharacterSet(charactersIn:"0123456789").inverted
            
            let components = string.components(separatedBy: inverseSet)
            
            let filtered = components.joined(separator: "")
            
            if filtered == string {
                return true
            } else {
                if string == "." {
                    let countdots = textField.text!.components(separatedBy:".").count - 1
                    if countdots == 0 {
                        return true
                    }
                    else {
                        if countdots > 0 && string == "." {
                            return false
                        } else {
                            return true
                        }
                    }
                }
                else {
                    return false
                }
            }
        }
        else { // You're looking at the name label. They can edit whatever they want.
            return true
        }
    }
}
