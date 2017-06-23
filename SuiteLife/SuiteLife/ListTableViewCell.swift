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

struct TextFieldType {
    static let name = 0
    static let price = 1
}

class ListTableViewCell: UITableViewCell, UITextFieldDelegate {

    let itemListInstance = ListDataModel.sharedInstance
    
    //MARK: Properties

    @IBOutlet weak var checkbox: M13Checkbox!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var priceLabel: UITextField!
    
    var storedText: String = ""
    
    var item: Item?
    
    weak var controller: ListTableViewController?
    
    func attachItem(_ newItem: inout Item) {
        
        item = newItem
        
        if item == itemListInstance.items.last { // Hide last item.
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
            priceLabel.text = String(format: "%d.%02d", item!.price/100, item!.price%100)
            
            // Label the labels.
            nameLabel.tag = TextFieldType.name
            priceLabel.tag = TextFieldType.price
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
        if textField.tag == TextFieldType.name { // If it's a name
            storedText = textField.text! // Keep the old text in this variable.
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // Edit the attributes in the array.
        item?.name = nameLabel.text ?? ""
        item?.checked = checkbox.value! as! Bool
        item?.price = cleanPrice(price: textField.text)
        priceLabel.text = String(format: "%d.%02d", item!.price/100, item!.price%100)
        
        if textField.tag == TextFieldType.name { // Did you just finish editing the name label?
            
            if item?.name == "" && storedText == "" { // You took this text and it was blank and now it's blank again.
                //Do nothing.
                
            }
            else if storedText == "" { // This cell is the last one, you want to replace the blank line.
                controller?.refreshPage()
            }
            else { // Delete this item, because you have made its text blank.
                itemListInstance.items.remove(at: (itemListInstance.items.index(of: item!))!) // Delete item.
                controller?.refreshPage() // Refresh the table.
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
    
    func cleanPrice(price: String?) -> Int { // Returns an int of cents. Format as you wish.
        print("Cleaning price: \(price!)")
        var dollars = 0
        var cents = 0
        
        if price == nil {
            print("Nil price.")
            return 0
        }
        else if !price!.characters.contains(".") { // No periods. Only dollars.
            dollars = Int(price!)!
        }
        else { // Extract dollars and cents from text field.
            let splitArray = price!.components(separatedBy: ".")
            dollars = Int(splitArray[0])!
            cents = Int(splitArray[1])!
            let centsPlaces = splitArray[1].characters.count // How many places of cents did they give us?
            if centsPlaces == 0 || centsPlaces == 2 {   // Not enough cents places (0). Cents should be zero anyway.
                                                        // OR enough cents places (2). In either case, don't do anything.
            }
            else if centsPlaces == 1 { // Not enough cents places (1).
                cents = cents * 10
            }
            else if centsPlaces > 2 { // Too many cents places.
                for i in 2..<centsPlaces {
                    print("going for time \(i)")
                    cents = cents/10
                }
            }
            else {
                fatalError("You have managed to input negative cents. Please stop.")
            }
        }
        
        print("dollars: \(dollars)\ncents: \(cents)")
        print("Here we go: \(dollars*100 + cents)")
        return dollars*100 + cents
    }
    
}
