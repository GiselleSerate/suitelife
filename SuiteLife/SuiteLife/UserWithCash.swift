//
//  UserWithCash.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/29/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//  For applications of the User class that require some sort of cash information.

import UIKit

class UserWithCash: User {
    
    var balance: Int // Currently assumes only one singular debt; this will probably change later. oh well
    
    init(name: String, handle: String, balance: Int) {
        self.balance = balance
        super.init(name: name, handle: handle)
    }
}
