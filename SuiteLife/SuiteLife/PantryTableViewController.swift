//
//  PantryTableViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/13/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import os.log
import Firebase

class PantryTableViewController: UITableViewController, UITextFieldDelegate {
    
    let itemListPantryInstance = ListPantryDataModel.sharedInstance
    
    let userID = Auth.auth().currentUser!.uid
    
    //MARK: View Transitions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Navigation configuration
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "We're Out", style: .plain, target: self, action: #selector(transferSelected(sender:)))
        
        // Load items into pantry. 
        print("Attempting to load Pantry items from memory...")
        loadItems()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("PantryView is appearing, checking to make sure the number of rows is consistent...")
        
        // Calculate the number of new rows required
        let numRows = tableView.numberOfRows(inSection: 0)
        let numNewRows = self.itemListPantryInstance.pantry.count - numRows
        
        if numNewRows > 0 {
            print("The number of rows is not consistent, adding in new rows...")
            let newIndeces = numRows ..< numRows + numNewRows
            print("New indeces to be added: \(newIndeces)")
            let newIndexPaths = newIndeces.map { index in
                IndexPath(row: index, section: 0)}
            // Add the rows
            tableView.insertRows(at: newIndexPaths, with: .automatic)
        }
        tableView.reloadData()
        
        print("Contents of PantryView's items \(self.itemListPantryInstance.pantry.map{item in item.name})")
        self.refreshPage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveItems()
    }
    
    //MARK: TableViewController Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // There's only one section
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of rows is equal to the number of items in the data model
        return itemListPantryInstance.pantry.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the cell
        let cellIdentifier = "PantryTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PantryTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of PantryTableViewCell.")
        }
        
        // Configure the cell with the item at its index in itemListPantryInstance.pantry
        var item = itemListPantryInstance.pantry[indexPath.row]
        cell.attachItem(&item)
        cell.controller = self
        return cell
    }
    
    // Support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            itemListPantryInstance.pantry.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Implement if we want an add item button
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Support conditional editing of the table view.
    // Return true if item should be editable, false otherwise
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == itemListPantryInstance.pantry.index(where: {$0.name == ""}) {
            // I don't want you to be able to drag my blank row. That's supposed to be at the bottom.
            return false
        }
        else {
            return true
        }
    }
    
    // Support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = itemListPantryInstance.pantry[fromIndexPath.row]
        itemListPantryInstance.pantry.remove(at: fromIndexPath.row)
        itemListPantryInstance.pantry.insert(itemToMove, at: to.row)
        if to.row == itemListPantryInstance.pantry.count - 1 { // When you move an item below the new item initialize slot, delete and recreate the blanks.
            // Possibly a little excessive; I could likely hard code deleting "second to last" instead of "all blanks"
            itemListPantryInstance.pantry = itemListPantryInstance.pantry.filter{$0.name != ""}
            itemListPantryInstance.pantry.append(Item(name: "", checked: false, price: 0))
            self.tableView.reloadData()
        }
    }
    
    
    //MARK: Firebase
    
    private func loadItems() { // Attempt to load saved pantry items.
        
        Database.database().reference().child("users/\(userID)/pantry").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let loadedItems = snapshot.value as? NSArray { // If we actually do have some file of items to load.
                self.itemListPantryInstance.pantry = loadedItems.map{Item(fromDictionary: $0 as! NSDictionary)}
                print("Loaded Pantry items.")
            }
            else {
                print("No saved Pantry items, loading defaults...")
                self.loadDefaults()
            }
            self.refreshPage()
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    func saveItems() {
        // Only the items that aren't blank get saved to file.
        itemListPantryInstance.pantry = itemListPantryInstance.pantry.filter{$0.name != ""}
        
        let items = itemListPantryInstance.pantry.map{(item) -> NSDictionary in return item.toDict()}
        
        Database.database().reference().child("users/\(userID)/pantry").setValue(items)
    }
    
    
    //MARK: Other Methods
    
    func loadDefaults() {
        let item1 = Item(name: "You don't have any items yet", checked: false, price: 0)
        let item2 = Item(name: "Add things here!", checked: false, price: 0)
        itemListPantryInstance.pantry = [item1, item2]
        refreshPage() // Add extra row.
    }
    
    func transferSelected(sender: UIBarButtonItem) {
        for item in itemListPantryInstance.pantry {
            if item.checked {
                item.checked = false // Reset checkedness.
                itemListPantryInstance.pantry = itemListPantryInstance.pantry.filter() {$0 != item} // Take the item out of the pantry.
                itemListPantryInstance.list.append(item) // Put the item into the list.
            }
        }
        saveItems() // Save to file.
        refreshPage()
    }
    
    
    func refreshPage() {
        print("REFRESH PANTRY")
        itemListPantryInstance.pantry = itemListPantryInstance.pantry.filter{$0.name != ""}
        itemListPantryInstance.pantry.append(Item(name: "", checked: false, price: 0)) // Do only once.
        tableView.reloadData()
    }
    
    
}
