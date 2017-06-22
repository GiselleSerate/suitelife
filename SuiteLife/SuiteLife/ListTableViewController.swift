//
//  ListTableViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/14/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import os.log

class ListTableViewController: UITableViewController, UITextFieldDelegate {
    
    let itemListInstance = ListDataModel.sharedInstance
    let itemPantryInstance = PantryDataModel.sharedInstance

    override func viewDidLoad() {
        
        // Superclass does . . .
        super.viewDidLoad()
        
        // Set up navbar items.
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Check Out", style: .plain, target: self, action: #selector(transferSelected(sender:)))
        
        // Load items into list.
        if let savedItems = loadItems() { // If we actually do have some file of items to load.
            itemListInstance.items = savedItems
        }
        else {
            loadDefaults()
        }
    

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.refreshPage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveItems()
        super.viewWillDisappear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    //MARK: Display
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemListInstance.items.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            itemListInstance.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert { // Possibly I could have implemented this instead of writing my own thing.
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.row == itemListInstance.items.index(where: {$0.name == ""}) { // I don't want you to be able to drag my blank row. That's supposed to be at the bottom.
            return false
        }
        else {
            return true
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = itemListInstance.items[fromIndexPath.row]
        itemListInstance.items.remove(at: fromIndexPath.row)
        itemListInstance.items.insert(itemToMove, at: to.row)
        if to.row == itemListInstance.items.count - 1 { // When you move an item below the new item initialize slot, delete and recreate the blanks.
            // Possibly a little excessive; I could likely hard code deleting "second to last" instead of "all blanks"
            refreshPage()
        }
    }
    
    
    //MARK: NSCoding
    
    private func loadItems() -> [Item]? { // Attempts to load saved list items, but only those that are not blank.
        print("Loading list items.")
        var fullList = NSKeyedUnarchiver.unarchiveObject(withFile: Item.ListArchiveURL.path) as? [Item]
        fullList?.append(Item(name: "", checked: false, price: 0))
        return fullList
    }
    
    func saveItems() {
        // Only the items that aren't blank get saved to file.
        itemListInstance.items = itemListInstance.items.filter{$0.name != ""}
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(itemListInstance.items, toFile: Item.ListArchiveURL.path)
        if isSuccessfulSave {
            os_log("Entire list successfully saved.", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save list.", log: OSLog.default, type: .error)
        }
    }
    
    
    //MARK: Transfer Items For Checkout
    
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
    
    
    //MARK: Refresh Page
    
    func refreshPage() {
        print("REFRESH LIST")
        itemListInstance.items = itemListInstance.items.filter{$0.name != ""}
        for _ in 0..<2 { // Do twice. Second one will be hidden.
            itemListInstance.items.append(Item(name: "", checked: false, price: 0))
        }
        tableView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func loadDefaults() {
        print("No list items saved, loading defaults.")
        let instruction1 = Item(name: "You don't have any items yet", checked: false, price: 0)
        let instruction2 = Item(name: "Add things here!", checked: false, price: 0)
        itemListInstance.items = [instruction1, instruction2]
        refreshPage() // Add extra row.
    }
    

}
