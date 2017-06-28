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

// TextFieldType struct defined in ListTableViewController.swift

class PantryTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    
    let itemListPantryInstance = ListPantryDataModel.sharedInstance
    
    
    //MARK: Properties
    
    @IBOutlet weak var checkbox: M13Checkbox!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var priceLabel: UITextField!
    
    var storedText: String = ""
    
    var item: Item?
    
    weak var controller: PantryTableViewController?
    
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
        
        // Set price label.
        priceLabel.text = PriceHelper.formatPrice(price: item!.price)
        
        // Label the labels.
        nameLabel.tag = TextFieldType.name
        priceLabel.tag = TextFieldType.price
        
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
        if textField.tag == TextFieldType.name { // If it's a name
            storedText = textField.text! // Keep the old text in this variable.
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Edit the attributes in the array.
        item?.name = nameLabel.text ?? ""
        item?.checked = checkbox.value! as! Bool
        item?.price = PriceHelper.cleanPrice(price: priceLabel.text)
        priceLabel.text = String(format: "%d.%02d", item!.price/100, item!.price%100)
        
        if textField.tag == TextFieldType.name { // Did you just finish editing a name label?
            
            if item?.name == "" && storedText == "" { // You took this text and it was blank and now it's blank again.
                // Do nothing.
            }
            else if storedText == "" { // This cell is the last one, you want to replace the blank line.
                itemListPantryInstance.pantry.append(Item(name: "", checked: false, price: 0))
                controller?.refreshPage()
            }
            else if item?.name == "" { // Delete this item, because you have made its text blank.
                itemListPantryInstance.pantry.remove(at: (itemListPantryInstance.pantry.index(of: item!))!) // Delete item.
                controller?.refreshPage() // Refresh the table.
            }
            else { // Allow an edit. Do nothing.
            }
            
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Limit the price field's allowable characters to be a decimal.
        if textField.tag == TextFieldType.price && string != ""{
            
            let inverseSetDot = NSCharacterSet(charactersIn:"0123456789.").inverted
            
            let components = string.components(separatedBy: inverseSetDot)
            
            let filtered = components.joined(separator: "")
            
            // String validation written assuming no pasting. Because pasting will break it. This is why I have extra validation in DidEndEditing.
            
            if filtered == string { // Typed/pasted string has only numbers or periods.
                if string.contains(".") && (textField.text?.contains("."))! { // Too many periods.
                    return false
                }
                else { // The add string has a period, or nothing has a period. We are assuming only one period in the add string, if any.
                    return true
                }
            }
            else { // The add string contains something you should not be able to add to a price, such as ?!*^.
                return false
            }
        }
        else { // You're looking at the name label. They can edit whatever they want.
            return true
        }
    }
}
