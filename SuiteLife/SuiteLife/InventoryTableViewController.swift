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
    
    // TODO: Should be in tab view controller???
    var groupIDs: [String] = ["personal"] // The groups the user is in.
    var groupNames: [String] = ["Personal"] // The names of this user's groups.
    
    // Can't be local, because callbacks. Eh.
    var balances: [String: [String: Int]] = [:]    // GroupID, then userID, then the amounts owed by the current user (so if we're paying, these should all be negative).
                                                    // Positive amounts are money that I should pay out.
    // TODO: Deprecate groupIDs and store it in balances?
    
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
        
        loadGroupIDs()
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
        
        return itemListPantryInstance.dict[type]!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of rows is equal to the number of items.
        return itemListPantryInstance.dict[type]![groupIDs[section]]!.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the cell...
        let cellIdentifier = "InventoryTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? InventoryTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of InventoryTableViewCell.")
        }
        
        // Configure the cell...
        let groupID = groupIDs[indexPath.section]
        var item = itemListPantryInstance.dict[type]![groupID]?[indexPath.row]
        
        cell.attachItem(&item!)
        cell.controller = self
        cell.type = self.type
        cell.groupID = groupID
        return cell
    }
    
    // Support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let groupID = groupIDs[indexPath.section]
            itemListPantryInstance.dict[type]![groupID]?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Implement if we want an add item button
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        let groupID = groupIDs[indexPath.section]
        if indexPath.row == itemListPantryInstance.dict[type]![groupID]?.index(where: {$0.name == ""}) {
            // I don't want you to be able to drag my blank row. That's supposed to be at the bottom.
            return false
        }
        else {
            return true
        }
    }
    
    // Support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = itemListPantryInstance.dict[type]![groupIDs[fromIndexPath.section]]?[fromIndexPath.row]
        itemListPantryInstance.dict[type]![groupIDs[fromIndexPath.section]]?.remove(at: fromIndexPath.row)
        itemListPantryInstance.dict[type]![groupIDs[to.section]]?.insert(itemToMove!, at: to.row)
        if to.row == (itemListPantryInstance.dict[type]![groupIDs[to.section]]?.count)! - 1 { // When you move an item below the new item initialize slot, delete and recreate the blanks.
            refreshPage()
        }
    }
    
    // Show header titles.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { // Ugh callbacks
        var text = "Loading . . . "
        if groupNames.count > section { // Presume we have loaded this many things.
            text = groupNames[section]
        }
        return text
    }
    
    
    //MARK: Firebase
    
    func loadGroupIDs() { // Put IDs into group IDs array.
        self.databaseRef.child("users/\(Auth.auth().currentUser!.uid)/groups").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                if let childRef = child as? DataSnapshot {
                    self.groupIDs.append(childRef.key)
                    self.balances[childRef.key] = [:] // Add empty dictionary line.
                }
            }
            print("Here are the IDs of groups you are in. \(self.groupIDs)")
            
            // Load items into list.
            print("Attempting to load \(self.type) items from memory...")
            self.loadItems() // Load items after callback has happened.
            self.loadGroupNames() // Less important to load names, but they exist. Call afterward.
            self.refreshPage()
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    func loadGroupNames() { // Just for header names.
        for groupID in groupIDs.filter({$0 != "personal"}) { // sssss
            self.databaseRef.child("groups/\(groupID)/name").observeSingleEvent(of: .value, with: {(snapshot) in
                self.groupNames.append(snapshot.value as! String)
                print("Here are the names of groups you are in. \(self.groupNames)")
            }) {(error) in
                print(error.localizedDescription)
            }
        }
    }

    private func loadItems() { // Attempts to load saved list items.
        // Loads personal items, since they save to a different place.
        databaseRef.child("users/\(userID)/\(type)").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let loadedItems = snapshot.value as? NSArray { // If we actually do have some file of items to load.
                self.itemListPantryInstance.dict[self.type]!["personal"] = loadedItems.map{Item(fromDictionary: $0 as! NSDictionary)}
                print("Loaded personal \(self.type) items.")
            }
            else {
                print("No saved personal \(self.type) items, loading defaults...")
                self.loadDefaults(groupID: "personal")
            }
            self.refreshPage()
        }) {(error) in
            print(error.localizedDescription)
        }
        // Loads group items.
        for groupID in groupIDs.filter({$0 != "personal"}) {
            databaseRef.child("groups/\(groupID)/\(type)").observeSingleEvent(of: .value, with: {(snapshot) in
                
                if let loadedItems = snapshot.value as? NSArray { // If we actually do have some file of items to load.
                    self.itemListPantryInstance.dict[self.type]![groupID] = loadedItems.map{Item(fromDictionary: $0 as! NSDictionary)}
                    print("Loaded \(self.type) items for group \(groupID).")
                }
                else {
                    print("No saved \(self.type) items for group \(groupID), loading defaults...")
                    self.loadDefaults(groupID: groupID)
                }
                self.refreshPage()
            }) {(error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func saveItems() {
        print("Saving \(self.type).")
        // Only the items that aren't blank get saved to file.
        for groupID in groupIDs {
            itemListPantryInstance.dict[type]![groupID] = itemListPantryInstance.dict[type]![groupID]?.filter{$0.name != ""}
            let items = itemListPantryInstance.dict[type]![groupID]?.map {$0.toDict()}
            if groupID == groupIDs.first {
                Database.database().reference().child("users/\(userID)/\(type)").setValue(items)
            }
            else {
                Database.database().reference().child("groups/\(groupID)/\(type)").setValue(items)
            }
        }
    }
    
    
    //MARK: Other Methods
    
    func loadDefaults(groupID: String) {
        let instruction1 = Item(name: "You don't have any items yet", checked: false, price: 0)
        let instruction2 = Item(name: "Add things here!", checked: false, price: 0)
        itemListPantryInstance.dict[type]![groupID] = [instruction1, instruction2]
        refreshPage()
    }
    
    func transferSelected(sender: UIBarButtonItem) {    // Transfers items from this inventory
                                                        // to the opposing inventory (list -> pantry or vice versa)

        
        for groupID in groupIDs {
            var balance = 0
            for thing in itemListPantryInstance.dict[type]![groupID]! {
                if thing.checked {
                    print(thing)
                    thing.checked = false // Reset checkedness.
                    itemListPantryInstance.dict[type]![groupID] = itemListPantryInstance.dict[type]![groupID]?.filter() {$0 != thing} // Take the item out of this inventory.
                    itemListPantryInstance.dict[notType]![groupID]?.append(thing) // Put the item into the opposing inventory.
                    if type == .list && groupID != "personal" { // We're checking out, and I want to record this as a debt.
                        print("Here is an add to the overall debt to the amount: \(thing.price) (a number of cents).")
                        balance = balance + thing.price
                    }
                }
            }
            // Remember that balance is positive. Here is how much you spent.
            if balance > 0 { // TODO: Maybe toast or alert this, to the effect of "Checking out with balance __. Are you sure?"
                recordGroupDebt(userID: Auth.auth().currentUser!.uid, groupID: groupID, amount: balance * -1)
            }
        }
        

        saveItems() // Save to file.
        refreshPage()
    }
    
    // TODO: how are we dealing with split cents? Randomly distribute extra cents; check if it doesn't add to total and add extra amount to the first person's total.
    func recordGroupDebt(userID: String, groupID: String, amount: Int) { // Records debt owed to this user by everyone in this group.
        
        // Amount here is a negative number.
        
        // Get members of this group from Firebase; they are in an array or the like.
        databaseRef.child("groups/\(groupID)/members").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                if let childRef = child as? DataSnapshot {
                    self.balances[groupID]?[childRef.key] = 0 // Set each person's balances to 0.
                }
            }

            let singleDebt = amount/self.balances[groupID]!.count
            var centsError = amount - singleDebt * self.balances[groupID]!.count // Some cents error needs to be fixed.
            
            for (key, value) in self.balances[groupID]! { // Fill the dictionary with debts to pass to recordPersonalDebts.
                self.balances[groupID]?[key] = singleDebt + centsError
                centsError = 0
            }
            self.recordPersonalDebts(debtDict: self.balances[groupID]!) // Calling helper function IN the callback.
            self.refreshPage()
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    func recordPersonalDebts(debtDict: [String: Int]) { // Takes a dictionary of userIDs and integers; the person now owes that much to the current user.
        for (userID, debt) in debtDict {
            if userID != Auth.auth().currentUser!.uid { // Don't bother owing yourself.
                // Write to my user that I am owed money (negative amount).
                recordSingleDebt(inUser: Auth.auth().currentUser!.uid, refUser: userID, amount: debt)
                // Write to their user that they owe me money (positive amount, negated from dictionary).
                recordSingleDebt(inUser: userID, refUser: Auth.auth().currentUser!.uid, amount: debt * -1)
            }
        }
    }
    
    func recordSingleDebt(inUser: String, refUser: String, amount: Int) { // Uses transaction operation to make sure we don't have race conditions when incrementing data.
        databaseRef.child("users/\(inUser)/debts/\(refUser)").runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
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
        }
    }
    
    func refreshPage() { // Removes all blank lines and re-adds a blank line at the end of the inventory.
        print("Refreshing \(type).")
        
        for groupID in groupIDs { // Refresh every group individually.
            itemListPantryInstance.dict[type]![groupID] = itemListPantryInstance.dict[type]![groupID]?.filter{$0.name != ""}
            itemListPantryInstance.dict[type]![groupID]?.append(Item(name: "", checked: false, price: 0)) // Do only once per group.
        }
        
        tableView.reloadData()
    }
    

}
