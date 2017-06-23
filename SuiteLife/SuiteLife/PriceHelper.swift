//
//  PriceHelper.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/23/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import Foundation

class PriceHelper {
    
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
            if splitArray[1] == "" {
                print("Ending on a period.")
            }
            else { // Not ending on a period. 
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
                    for _ in 2..<centsPlaces { // I'm truncating the cents here because slicing isn't particularly Pythonic.
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

}
