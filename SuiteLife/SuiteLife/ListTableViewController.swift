//
//  ListTableViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/14/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import os.log
import Firebase

class ListTableViewController: UITableViewController, UITextFieldDelegate {
    
    let itemListInstance = ListDataModel.sharedInstance
    let itemPantryInstance = PantryDataModel.sharedInstance
    
    let userID = Auth.auth().currentUser!.uid
    
    //MARK: View Transitions

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Set up navbar items.
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Check Out", style: .plain, target: self, action: #selector(transferSelected(sender:)))
        
        // Load items into list.
        print("Attempting to load List items from memory...")
        loadItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Maybe this will help i do't know
        print("PantryView is appearing, checking to make sure the number of rows is consistent...")
        
        // Calculate the number of new rows required
        let numRows = tableView.numberOfRows(inSection: 0)
        let numNewRows = self.itemListInstance.items.count - numRows
        
        if numNewRows > 0 {
            print("The number of rows is not consistent, adding in new rows...")
            let newIndeces = numRows ..< numRows + numNewRows
            print("New indeces to be added: \(newIndeces)")
            let newIndexPaths = newIndeces.map { index in
                IndexPath(row: index, section: 0)}
            // Add the rows
            tableView.insertRows(at: newIndexPaths, with: .automatic)
        }
        // end helpage
        
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
        // There's only one section.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of rows is equal to the number of items.
        return itemListInstance.items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the cell...
        let cellIdentifier = "ListTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ListTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of ListTableViewCell.")
        }
        
        // Configure the cell...
        var item = itemListInstance.items[indexPath.row]
        cell.attachItem(&item)
        cell.controller = self
        return cell
    }
    
    // Support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            itemListInstance.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Implement if we want an add item button
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.row == itemListInstance.items.index(where: {$0.name == ""}) {
            // I don't want you to be able to drag my blank row. That's supposed to be at the bottom.
            return false
        }
        else {
            return true
        }
    }
    
    // Support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = itemListInstance.items[fromIndexPath.row]
        itemListInstance.items.remove(at: fromIndexPath.row)
        itemListInstance.items.insert(itemToMove, at: to.row)
        if to.row == itemListInstance.items.count - 1 { // When you move an item below the new item initialize slot, delete and recreate the blanks.
            // Possibly a little excessive; I could likely hard code deleting "second to last" instead of "all blanks"
            refreshPage()
        }
    }
    
    
    //MARK: Firebase
    
    private func loadItems() { // Attempts to load saved list items.
        
        Database.database().reference().child("users/\(userID)/list").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let loadedItems = snapshot.value as? NSArray { // If we actually do have some file of items to load.
                self.itemListInstance.items = loadedItems.map{Item(fromDictionary: $0 as! NSDictionary)}
                print("Loaded List items.")
            }
            else {
                print("No saved List items, loading defaults...")
                self.loadDefaults()
            }
            self.refreshPage()
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    func saveItems() {
        // Only the items that aren't blank get saved to file.
        itemListInstance.items = itemListInstance.items.filter{$0.name != ""}
        
        let items = itemListInstance.items.map{(item) -> NSDictionary in return item.toDict()}
        
        Database.database().reference().child("users/\(userID)/list").setValue(items)
    }
    
    
    //MARK: Other Methods
    
    func loadDefaults() {
        let instruction1 = Item(name: "You don't have any items yet", checked: false, price: 0)
        let instruction2 = Item(name: "Add things here!", checked: false, price: 0)
        itemListInstance.items = [instruction1, instruction2]
        refreshPage()
    }
    
    func transferSelected(sender: UIBarButtonItem) {
        for thing in itemListInstance.items {
            if thing.checked {
                thing.checked = false // Reset checkedness.
                itemListInstance.items = itemListInstance.items.filter() {$0 != thing} // Take the item out of the list.
                itemPantryInstance.items.append(thing) // Put the item into the pantry.
            }
        }
        saveItems() // Save to file.
        refreshPage()
    }

    
    func refreshPage() {
        print("REFRESH LIST")
        itemListInstance.items = itemListInstance.items.filter{$0.name != ""}
        itemListInstance.items.append(Item(name: "", checked: false, price: 0)) // Do only once.
        tableView.reloadData()
    }
    

}
