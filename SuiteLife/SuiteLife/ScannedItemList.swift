//
//  ScannedItemList.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/16/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import Foundation

// Singleton to contain the items scanned by BarcodeScannerController.

class ScannedItemList {
    static var sharedInstance = ScannedItemList()
    private init() {}
    
    var items = [Item]()
    
}
