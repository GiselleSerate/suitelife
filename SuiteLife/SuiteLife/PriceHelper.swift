//
//  PriceHelper.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/23/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import Foundation

class PriceHelper {
    
    static func validatePrice(price: String, alreadyText: String) -> Bool {
        let inverseSetDot = NSCharacterSet(charactersIn:"0123456789.").inverted
        
        let components = price.components(separatedBy: inverseSetDot)
        
        let filtered = components.joined(separator: "")
        
        // String validation written assuming no pasting. Because pasting will break it. This is why I have extra validation in DidEndEditing.
        
        if filtered == price { // Typed/pasted string has only numbers or periods.
            if price.contains(".") && (alreadyText.contains(".")) { // Too many periods.
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
    
    static func cleanPrice(price: String?) -> Int { // Returns an int of cents. Format as you wish upon return.
        
        print("I am being asked to clean '\(price!)'.")
        
        var dollars = 0
        var cents = 0
        
        if price == nil {
            return 0
        }
        else if !price!.characters.contains(".") { // No periods. Only dollars.
            dollars = Int(price!)!
        }
        else { // Extract dollars and cents from text field.
            let splitArray = price!.components(separatedBy: ".")
            if splitArray[1] == "" { // If cents is empty.
                dollars = Int(splitArray[0])!
            }
            else { // Not ending on a period.
                if splitArray[0] != "" { // If dollars is not empty.
                    dollars = Int(splitArray[0])!
                }
                cents = Int(splitArray[1])!
                let centsPlaces = splitArray[1].characters.count // How many places of cents did they give us?
                
                if centsPlaces == 0 || centsPlaces == 2 {   // Not enough cents places (0). Cents should be zero anyway.
                                                            // OR enough cents places (2). In either case, don't do anything.
                }
                else if centsPlaces == 1 { // Not enough cents places (1).
                    cents = cents * 10
                }
                else if centsPlaces > 2 { // Too many cents places.
                    for _ in 2..<centsPlaces { // I'm truncating the cents here because slicing in Swift isn't particularly Pythonic.
                        cents = cents/10
                    }
                }
                else {
                    fatalError("You have managed to input negative cents. Please stop.")
                }
            }
        }
        
        return dollars*100 + cents
    }
    
    static func formatPrice(price: Int) -> String {
        return String(format: "%d.%02d", price/100, price%100)
    }
    
    static func formatPriceDollarSign(price: Int) -> String {
        if price < 0 { // Negative.
            let absPrice = abs(price)
            return String(format: "-$%d.%02d", absPrice/100, absPrice%100)
        }
        return String(format: "$%d.%02d", price/100, price%100)
    }

}
