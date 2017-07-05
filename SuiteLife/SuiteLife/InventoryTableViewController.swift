//
//  InventoryTableViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/14/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import os.log
import Firebase

class InventoryTableViewController: UITableViewController, UITextFieldDelegate {

    let databaseRef = Database.database().reference()
    
    var groupIDs: [String] = [] // The groups the user is in.
    
    //MARK: Properties
    
    var type: InventoryType = .list // By default, the view controller's type will be list.
    var notType: InventoryType = .pantry
    
    let itemListPantryInstance = ListPantryDataModel.sharedInstance
    
    let userID = Auth.auth().currentUser!.uid
    
    func setType(type: InventoryType) {
        if type == .pantry { // Switch the controller's type to pantry. Else, leave it as default, which is list.
            self.type = .pantry
            self.notType = .list
        }
    }
    
    
    //MARK: View Transitions

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        var title = "Check Out"
        if type == .pantry {
            title = "We're Out"
        }
        
        // Set up navbar items.
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(transferSelected(sender:)))
        
        // Load items into list.
        print("Attempting to load \(type) items from memory...")
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.refreshPage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        saveItems()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    //MARK: TableViewController Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of rows is equal to the number of items.
        return itemListPantryInstance.dict[type]!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the cell...
        let cellIdentifier = "InventoryTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? InventoryTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of InventoryTableViewCell.")
        }
        
        // Configure the cell...
        var item = itemListPantryInstance.dict[type]?[indexPath.row]
        
        cell.attachItem(&item!)
        cell.controller = self
        cell.type = self.type
        return cell
    }
    
    // Support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            itemListPantryInstance.dict[type]!.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Implement if we want an add item button
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        if indexPath.row == itemListPantryInstance.dict[type]?.index(where: {$0.name == ""}) {
            // I don't want you to be able to drag my blank row. That's supposed to be at the bottom.
            return false
        }
        else {
            return true
        }
    }
    
    // Support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = itemListPantryInstance.dict[type]?[fromIndexPath.row]
        itemListPantryInstance.dict[type]!.remove(at: fromIndexPath.row)
        itemListPantryInstance.dict[type]!.insert(itemToMove!, at: to.row)
        if to.row == (itemListPantryInstance.dict[type]?.count)! - 1 { // When you move an item below the new item initialize slot, delete and recreate the blanks.
            refreshPage()
        }
    }
    
    
    //MARK: Firebase
    
    func loadGroupIDs() { // Put IDs into group IDs array.
        self.databaseRef.child("users/\(Auth.auth().currentUser!.uid)/groups").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                if let childRef = child as? DataSnapshot {
                    self.groupIDs.append(childRef.key)
                }
            }
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    private func loadItems() { // Attempts to load saved list items.
        
        Database.database().reference().child("users/\(userID)/\(type)").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let loadedItems = snapshot.value as? NSArray { // If we actually do have some file of items to load.
                self.itemListPantryInstance.dict[self.type] = loadedItems.map{Item(fromDictionary: $0 as! NSDictionary)}
                print("Loaded \(self.type) items.")
            }
            else {
                print("No saved \(self.type) items, loading defaults...")
                self.loadDefaults()
            }
            self.refreshPage()
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    func saveItems() {
        // Only the items that aren't blank get saved to file.
        itemListPantryInstance.dict[type] = itemListPantryInstance.dict[type]?.filter{$0.name != ""}
        let items = itemListPantryInstance.dict[type]?.map {$0.toDict()}
        Database.database().reference().child("users/\(userID)/\(type)").setValue(items)
    }
    
    
    //MARK: Other Methods
    
    func loadDefaults() {
        let instruction1 = Item(name: "You don't have any items yet", checked: false, price: 0)
        let instruction2 = Item(name: "Add things here!", checked: false, price: 0)
        itemListPantryInstance.dict[type] = [instruction1, instruction2]
        refreshPage()
    }
    
    func transferSelected(sender: UIBarButtonItem) {    // Transfers items from this inventory
                                                        // to the opposing inventory (list -> pantry or vice versa)
        for thing in itemListPantryInstance.dict[type]! {
            if thing.checked {
                print(thing)
                thing.checked = false // Reset checkedness.
                itemListPantryInstance.dict[type] = itemListPantryInstance.dict[type]?.filter() {$0 != thing} // Take the item out of this inventory.
                itemListPantryInstance.dict[notType]!.append(thing) // Put the item into the opposing inventory.
            }
        }
        saveItems() // Save to file.
        refreshPage()
    }
    
    func refreshPage() { // Removes all blank lines and re-adds a blank line at the end of the inventory.
        print("Refreshing \(type).")
        itemListPantryInstance.dict[type] = itemListPantryInstance.dict[type]?.filter{$0.name != ""}
        itemListPantryInstance.dict[type]!.append(Item(name: "", checked: false, price: 0)) // Do only once.
        tableView.reloadData()
    }
    

}
