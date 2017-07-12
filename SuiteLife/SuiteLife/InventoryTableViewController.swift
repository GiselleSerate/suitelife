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
    
    
    //MARK: Properties
    
    // Constants to find the user, database, local item arrays.
    let userID = Auth.auth().currentUser!.uid
    let databaseRef = Database.database().reference()
    let itemListPantryInstance = ListPantryDataModel.sharedInstance
    
    // Loading alert.
    var alert: UIAlertView = UIAlertView(title: "", message: nil, delegate: nil, cancelButtonTitle: nil);
    
    // Arrays to track what groups you are in.
    var groupIDs: [String] = ["personal"] // The groups the user is in.
    var groupNames: [String] = ["Personal"] // The names of this user's groups.
    
    // Balance tracker.
    var balances: [String: [String: Int]] = [:]    // GroupID, then userID, then the amounts owed by the current user (so if we're paying, these should all be negative).
                                                    // Positive amounts are money that I should pay out.
    
    // Item buffers.
    var transferItems: [String:[Item]] = [:]    // Contains groupID keys with arrays of Items to move to the opposing inventory.
    var toDelete: [String: [String]] = [:]      // Contains groupID keys with arrays of strings to delete.
    
    var type: InventoryType = .list // By default, the view controller's type will be list.
    var notType: InventoryType = .pantry
    
    
    func setType(type: InventoryType) { // Called on initialization of this controller.
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
        
        // Handle pull to refresh.
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadGroupIDs()
        toDelete = [:] // Reset delete buffer to be empty.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        saveItems()
    }

   
    //MARK: TableViewController Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return itemListPantryInstance.dict[type]!.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Make sure that section is bounded properly -- i.e. that groupIDs has loaded in.
        if groupIDs.count > section {
            return itemListPantryInstance.dict[type]![groupIDs[section]]?.count ?? 0
        }
        else { // We must not have loaded yet.
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the cell...
        let cellIdentifier = "InventoryTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? InventoryTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of InventoryTableViewCell.")
        }
        
        // Configure the cell.
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
            // Discover the group the items are from.
            let groupID = groupIDs[indexPath.section]
            
            // Store these items to be deleted upon save.
            if var tempDelete = toDelete[groupID] {
                tempDelete.append((itemListPantryInstance.dict[type]![groupID]?[indexPath.row].uid.uuidString)!)
                toDelete[groupID] = tempDelete
            }
            else {
                toDelete[groupID] = [(itemListPantryInstance.dict[type]![groupID]?[indexPath.row].uid.uuidString)!]
            }
            
            // Delete these items from the local data source.
            itemListPantryInstance.dict[type]![groupID]?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let groupID = groupIDs[indexPath.section]
        if indexPath.row == itemListPantryInstance.dict[type]![groupID]?.index(where: {$0.name == ""}) {
            // You should not be able to edit my blank row.
            return false
        }
        else {
            return true
        }
    }
    
    // Support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        // Perform basic swap of items.
        let itemToMove = itemListPantryInstance.dict[type]![groupIDs[fromIndexPath.section]]?[fromIndexPath.row]
        itemListPantryInstance.dict[type]![groupIDs[fromIndexPath.section]]?.remove(at: fromIndexPath.row)
        itemListPantryInstance.dict[type]![groupIDs[to.section]]?.insert(itemToMove!, at: to.row)
        
        // When you move an item below the blank (new item) slot, delete and recreate the blanks.
        if to.row == (itemListPantryInstance.dict[type]![groupIDs[to.section]]?.count)! - 1 {
            shallowRefresh()
        }
    }
    
    // Show header titles.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var text = "Loading . . . " // If you have not loaded the names yet, display this text.
        if groupNames.count > section { // Presume we have loaded this many things.
            text = groupNames[section] // We have a group name for this section.
        }
        return text
    }
    
    
    //MARK: Firebase
    
    func loadGroupIDs() { // Put IDs into group IDs array.
        startSpinner()
        self.databaseRef.child("users/\(Auth.auth().currentUser!.uid)/groups").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                if let childRef = child as? DataSnapshot {
                    if !self.groupIDs.contains(childRef.key) {
                        self.groupIDs.append(childRef.key)
                        self.balances[childRef.key] = [:] // Add empty dictionary line.
                    }
                }
            }
            // self.groupIDs now contains the IDs of the groups that you are in.
            
            // Load items into list.
            print("Attempting to load \(self.type) items from memory...")
            self.loadGroupNames() // Less important to load names, but they exist. Call afterward.
            self.loadItems() // Load items after callback has happened.
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    func loadGroupNames() { // For header names, get the names of the groups you're in.
        for groupID in groupIDs.filter({$0 != "personal"}) {
            self.databaseRef.child("groups/\(groupID)/name").observeSingleEvent(of: .value, with: {(snapshot) in
                if !self.groupNames.contains(snapshot.value as! String) {
                    self.groupNames.append(snapshot.value as! String)
                }
                self.shallowRefresh()
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
            
            if self.groupIDs.count == 1 { // I am not in any groups besides my personal list.
                self.shallowRefresh()
                self.stopSpinner()
            }
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
                
                if groupID == self.groupIDs.last {
                    self.shallowRefresh()
                    self.stopSpinner()
                }
            }) {(error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func saveItems() {
        print("Saving \(self.type).")
        
        // Iterate over groups.
        for groupID in groupIDs {
            
            // Only the items that aren't blank get saved to file.
            itemListPantryInstance.dict[type]![groupID] = itemListPantryInstance.dict[type]![groupID]?.filter{$0.name != ""}
            
            // Set reference according to whether you're saving to the personal or group location.
            var myRef = Database.database().reference().child("groups/\(groupID)/\(type)")
            if groupID == groupIDs.first {
                myRef = Database.database().reference().child("users/\(userID)/\(type)")
            }
            
            // Transaction block that updates the array with the locally displayed values, excluding duplicates.
            myRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                let newItems = self.itemListPantryInstance.dict[self.type]![groupID]!.map{$0.toDict()}  as! [[String:Any]]
                var newArray: [[String: Any]] = []
                if var data = currentData.value as? [[String: Any]] { // The database has returned some data.
                    for item in newItems {
                        // Duplicates checked by uuids.
                        // Adding:
                        if !(data.contains{$0["uidString"] as! String == item["uidString"] as! String}) { // I have an item that the database does not have.
                            data.append(item)
                        }
                        // Editing:
                        else { // If it is a duplicate, support editing. This will probably make editing slightly unreliable, but adding should be bulletproof.
                            let dataIndex = data.index(where: {$0["uidString"] as! String == item["uidString"] as! String})
                            data[dataIndex!]["name"] = item["name"]
                            data[dataIndex!]["checked"] = item["checked"]
                            data[dataIndex!]["price"] = item["price"]
                        }
                    }
                    
                    // Deleting:
                    var filteredData: [[String: Any]]
                    if let deleteStrings = self.toDelete[groupID] { // If there are things to delete, filter them out.
                        filteredData = data.filter{!self.toDelete[groupID]!.contains($0["uidString"] as! String)}
                    }
                    else {
                        filteredData = data
                    }
                    
                    print("Save NONNIL: The new \(self.type) is \(filteredData).")
                    currentData.value = filteredData as! NSArray
                }
                else { // There was no data returned by the database yet.
                    print("Save NIL: Waiting on database.")
                }
                return TransactionResult.success(withValue: currentData)
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            
            
        }
    }
    
    
    // MARK: Checkout
    
    func transferSelected(sender: UIBarButtonItem) {    // Transfers items from this inventory to the opposing inventory

        for groupID in groupIDs {
            
            transferItems[groupID] = [] // Empty the buffer of items to transfer for this group.
            var balance = 0 // The balance for each group.
            
            // Iterate over the list (or pantry) of this group.
            for thing in itemListPantryInstance.dict[type]![groupID]! {
                if thing.checked {
                    print(thing)
                    thing.checked = false // Reset checkedness.
                    itemListPantryInstance.dict[type]![groupID] = itemListPantryInstance.dict[type]![groupID]?.filter() {$0 != thing} // Take the item out of this inventory.
                    itemListPantryInstance.dict[notType]![groupID]?.append(thing) // Put the item into the opposing inventory.
                    transferItems[groupID]!.append(thing)
                    
                    // Put checkout item into deletion buffer.
                    if var tempDelete = toDelete[groupID] {
                        tempDelete.append(thing.uid.uuidString)
                        toDelete[groupID] = tempDelete
                    }
                    else {
                        toDelete[groupID] = [thing.uid.uuidString]
                    }
                    
                    if type == .list && groupID != "personal" { // We're checking out, and I want to record this as a debt.
                        print("Here is an add to the overall debt to the amount: \(thing.price) (a number of cents).")
                        balance = balance + thing.price
                    }
                }
            }
            
            // Prepare to transfer items by setting reference location.
            var myRef = databaseRef.child("groups/\(groupID)/\(notType)")
            if groupID == "personal" {
                myRef = databaseRef.child("users/\(userID)/\(notType)")
            }
            
            // Transaction block that updates the database with the locally displayed values, excluding duplicates.
            myRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
                var newItems = self.transferItems[groupID]!.map{$0.toDict()}  as! [[String:Any]]
                var newArray: [[String: Any]] = []
                if var data = currentData.value as? [[String: Any]] { // The database has returned with our data.
                    for item in newItems {
                        data.append(item as! [String : Any])
                    }
                    print("Transfer NONNIL: The new \(self.notType) is \(data).")
                    currentData.value = data as! NSArray
                }
                else { // The database has not yet returned with our data.
                    print("Transfer NIL: Waiting for database.")
                }
                return TransactionResult.success(withValue: currentData)
                
            }) { (error, committed, snapshot) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            
            // Remember that balance is positive. Here is how much you spent.
            if balance > 0 { // TODO: Maybe toast or alert this, to the effect of "Checking out with balance __. Are you sure?"
                recordGroupDebt(userID: Auth.auth().currentUser!.uid, groupID: groupID, amount: balance * -1)
            }
        }
        
        
        
        saveItems() // Save to file.
        shallowRefresh()
    }
    
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
            
            // Randomly distribute extra cents; check if it doesn't add to total and add extra amount progressively to people's totals. This shouldn't be more than how many people there are, so you should run out of centsError by the time you get to the end of the people.
            
            for (key, value) in self.balances[groupID]! { // Fill the dictionary with debts to pass to recordPersonalDebts.
                if centsError > 0 {
                    self.balances[groupID]?[key] = singleDebt + 1
                    centsError = centsError - 1
                }
                else {
                    self.balances[groupID]?[key] = singleDebt
                }
            }
            DebtHelper.recordPersonalDebts(debtDict: self.balances[groupID]!, onCompletion: nil)
        }) {(error) in
            print(error.localizedDescription)
        }
    }

    
    //MARK: Default Handling
    
    func loadDefaults(groupID: String) { // Load a single item into the list (or pantry).
        let instruction1 = Item(name: "Add items to your \(type) here!", checked: false, price: 0)
        itemListPantryInstance.dict[type]![groupID] = [instruction1]
        shallowRefresh()
    }
    
    
    // MARK: Refresh
    
    func handleRefresh(_ refreshControl: UIRefreshControl) { // Triggered on pull to refresh.
        loadGroupIDs()
        refreshControl.endRefreshing()
    }
    
    func shallowRefresh() { // Refreshes from local source (essentially wrapper for reloadData).
        
        // Removes all blank lines and re-adds a blank line at the end of the inventory.
        print("Refreshing \(type).")
        for groupID in groupIDs { // Refresh every group individually.
            itemListPantryInstance.dict[type]![groupID] = itemListPantryInstance.dict[type]![groupID]?.filter{$0.name != ""}
            itemListPantryInstance.dict[type]![groupID]?.append(Item(name: "", checked: false, price: 0)) // Do only once per group.
        }
        
        tableView.reloadData()
    }
    
    // MARK: Loading
    
    func startSpinner() { // Start loading animation.
        
        var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 50, y: 10, width: 37, height: 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating()
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        alert.show()
        self.view.isUserInteractionEnabled = false
        self.navigationController!.view.isUserInteractionEnabled = false
    }
    
    func stopSpinner() { // Stop loading animation.
        alert.dismiss(withClickedButtonIndex: 0, animated: true)
        self.view.isUserInteractionEnabled = true
        self.navigationController!.view.isUserInteractionEnabled = true
    }

}
