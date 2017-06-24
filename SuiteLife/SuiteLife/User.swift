//
//  User.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/23/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import Foundation

class User {
    //MARK: Properties
    var name: String
    var handle: String // Venmo handle? Twitter handle? I don't care.
    var balance: Int // Currently assumes only one singular debt; this will probably change later. oh well
    
    init(name: String, handle: String, balance: Int) {
        self.name = name
        self.handle = handle
        self.balance = balance
    }
}
