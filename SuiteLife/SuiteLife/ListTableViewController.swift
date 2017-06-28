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
    
    let itemListPantryInstance = ListPantryDataModel.sharedInstance
    
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
        return itemListPantryInstance.list.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the cell...
        let cellIdentifier = "ListTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ListTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of ListTableViewCell.")
        }
        
        // Configure the cell...
        var item = itemListPantryInstance.list[indexPath.row]
        cell.attachItem(&item)
        cell.controller = self
        return cell
    }
    
    // Support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            itemListPantryInstance.list.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Implement if we want an add item button
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.row == itemListPantryInstance.list.index(where: {$0.name == ""}) {
            // I don't want you to be able to drag my blank row. That's supposed to be at the bottom.
            return false
        }
        else {
            return true
        }
    }
    
    // Support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = itemListPantryInstance.list[fromIndexPath.row]
        itemListPantryInstance.list.remove(at: fromIndexPath.row)
        itemListPantryInstance.list.insert(itemToMove, at: to.row)
        if to.row == itemListPantryInstance.list.count - 1 { // When you move an item below the new item initialize slot, delete and recreate the blanks.
            // Possibly a little excessive; I could likely hard code deleting "second to last" instead of "all blanks"
            refreshPage()
        }
    }
    
    
    //MARK: Firebase
    
    private func loadItems() { // Attempts to load saved list items.
        
        Database.database().reference().child("users/\(userID)/list").observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let loadedItems = snapshot.value as? NSArray { // If we actually do have some file of items to load.
                self.itemListPantryInstance.list = loadedItems.map{Item(fromDictionary: $0 as! NSDictionary)}
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
        itemListPantryInstance.list = itemListPantryInstance.list.filter{$0.name != ""}
        
        let items = itemListPantryInstance.list.map{(item) -> NSDictionary in return item.toDict()}
        
        Database.database().reference().child("users/\(userID)/list").setValue(items)
    }
    
    
    //MARK: Other Methods
    
    func loadDefaults() {
        let instruction1 = Item(name: "You don't have any items yet", checked: false, price: 0)
        let instruction2 = Item(name: "Add things here!", checked: false, price: 0)
        itemListPantryInstance.list = [instruction1, instruction2]
        refreshPage()
    }
    
    func transferSelected(sender: UIBarButtonItem) {
        for thing in itemListPantryInstance.list {
            if thing.checked {
                thing.checked = false // Reset checkedness.
                itemListPantryInstance.list = itemListPantryInstance.list.filter() {$0 != thing} // Take the item out of the list.
                itemListPantryInstance.pantry.append(thing) // Put the item into the pantry.
            }
        }
        saveItems() // Save to file.
        refreshPage()
    }

    
    func refreshPage() {
        print("REFRESH LIST")
        itemListPantryInstance.list = itemListPantryInstance.list.filter{$0.name != ""}
        itemListPantryInstance.list.append(Item(name: "", checked: false, price: 0)) // Do only once.
        tableView.reloadData()
    }
    

}
