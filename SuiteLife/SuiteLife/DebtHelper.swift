//
//  DebtHelper.swift
//  SuiteLife
//
//  Created by cssummer17 on 7/6/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import Foundation
import Firebase

class DebtHelper {
    
    static func recordPersonalDebts(debtDict: [String: Int], onCompletion: (()->Void)?) { // Takes a dictionary of userIDs and integers; the person now owes that much to the current user.
        for (userID, debt) in debtDict {
            if userID != Auth.auth().currentUser!.uid { // Don't bother owing yourself.
                // Write to my user that I am owed money (negative amount).
                recordSingleDebt(inUser: Auth.auth().currentUser!.uid, refUser: userID, amount: debt, onCompletion: nil)
                // Write to their user that they owe me money (positive amount, negated from dictionary).
                recordSingleDebt(inUser: userID, refUser: Auth.auth().currentUser!.uid, amount: debt * -1, onCompletion: onCompletion)
            }
        }
    }
    
    static func recordSingleDebt(inUser: String, refUser: String, amount: Int, onCompletion: (() -> Void)?) { // Uses transaction operation to make sure we don't have race conditions when incrementing data.
        print("Called recordSingleDebt. Woo.")
        Database.database().reference().child("users/\(inUser)/debts/\(refUser)").runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            print("Putting in user tree of \(inUser) wrt user \(refUser) with amt \(amount).")
            var newAmount = 0
            if let oldData = currentData.value as? Int { // Why this running so much?
                newAmount = oldData + amount
                print("The existing amount is \(oldData).")
            }
            else { // There is no existing balance, or we cannot find it.                 self.balances[groupID]?[childRef.key] = 0 // Set each person's balances to 0.
                newAmount = amount
            }
            print("The new amount is \(newAmount).")
            currentData.value = newAmount

            return TransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
            if committed {
                onCompletion!()
            }
        }
    }
}
