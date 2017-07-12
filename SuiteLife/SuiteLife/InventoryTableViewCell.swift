//
//  InventoryTableViewCell.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/13/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import os.log
import M13Checkbox

struct TextFieldType {
    static let name = 0
    static let price = 1
}

class InventoryTableViewCell: UITableViewCell, UITextFieldDelegate {

    
    //MARK: Properties

    @IBOutlet weak var checkbox: M13Checkbox!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var priceLabel: UITextField!
    
    let itemListPantryInstance = ListPantryDataModel.sharedInstance
    
    var storedText: String = ""
    
    var item: Item?
    
    weak var controller: InventoryTableViewController?
    
    var type: InventoryType = .list     // By default, the cell is of type list.
    
    var groupID: String?
    
    //MARK: Item Initializer
    
    func attachItem(_ newItem: inout Item) { // Attaches inout to all of this cell's fields.
        
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
    
    // The internet tells me this function is called reasonably first and often as you scroll around. They lied about "often."
    // Treating as viewDidLoad.
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
        if textField.tag == TextFieldType.name { // If the text field you're editing is a name field.
            storedText = textField.text! // Keep the old text in this variable.
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Edit the attributes in the array.
        item?.name = nameLabel.text ?? ""
        item?.checked = checkbox.value! as! Bool
        item?.price = PriceHelper.cleanPrice(price: priceLabel.text)
        priceLabel.text = String(format: "%d.%02d", item!.price/100, item!.price%100)
        
        if textField.tag == TextFieldType.name { // Did you just finish editing the name label?
            
            if item?.name == "" && storedText == "" { // You took this text and it was blank and now it's blank again.
                //Do nothing.
            }
            else if storedText == "" { // This cell is the last one, you want to replace the blank line.
                controller?.shallowRefresh()
            }
            else if item?.name == "" { // Delete this item, because you have made its text blank.
                itemListPantryInstance.dict[type]![groupID!]!.remove(at: (itemListPantryInstance.dict[type]![groupID!]!.index(of: item!))!) // Delete item.
                controller?.shallowRefresh() // Refresh the table.
            }
            else { // Allow an edit. Do nothing. 
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Limit the price field's allowable characters to be a decimal with numbers and a single period.
        if textField.tag == TextFieldType.price && string != ""{
            return PriceHelper.validatePrice(price: string, alreadyText: textField.text!)
            
        }
        else { // You're looking at the name label. They can edit whatever they want.
            return true
        }
    }
    
}
