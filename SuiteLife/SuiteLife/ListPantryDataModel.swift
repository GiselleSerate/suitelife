//
//  ListPantryDataModel.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/20/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//
//  List has stuff in it, here we create a singleton to handle all of these stuffs.

import Foundation

class ListPantryDataModel {

    static var sharedInstance = ListPantryDataModel()
    
    private init() { }
    
    var list = [Item]()
    var pantry = [Item]()
    
}
