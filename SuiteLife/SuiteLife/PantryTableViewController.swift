//
//  PantryTableViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/13/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import os.log

class PantryTableViewController: ItemTableViewController, UITextFieldDelegate {
    
    let itemListInstance = ListDataModel.sharedInstance
    let itemPantryInstance = PantryDataModel.sharedInstance
    
    override func viewDidLoad() {
        
        navigationItem.leftBarButtonItem = editButtonItem
        
        super.viewDidLoad()
        if let savedItems = loadItems() { // If we actually do have some file of items to load.
            itemPantryInstance.items = savedItems // Loads from file every time you switch tabs.
        }
        else {
            loadDefaults()
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("PantryView is appearing, checking to make sure the number of rows is consistent...")
        print("Contents of items \(self.itemPantryInstance.items.map{item in item.name})")
        
        let numRows = tableView.numberOfRows(inSection: 0)
        let numNewRows = self.itemPantryInstance.items.count - numRows
        if numNewRows > 0 {
            let newIndeces = numRows ..< numRows + numNewRows
            print("New indeces to be added: \(newIndeces)")
            let newIndexPaths = newIndeces.map { index in
                IndexPath(row: index, section: 0)}
            // Add the rows
            tableView.insertRows(at: newIndexPaths, with: .automatic)
        }
        tableView.reloadData()
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemPantryInstance.items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PantryTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? PantryTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of PantryTableViewCell.")
        }
        
        // Configure the cell...
        var item = itemPantryInstance.items[indexPath.row]
        cell.attachItem(&item)
        cell.controller = self
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            print("indexPath.row is \(indexPath.row)")
            itemPantryInstance.items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert { // Possibly I could have implemented this instead of writing my own thing.
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
//        if indexPath.row == itemPantryInstance.items.index(where: {$0.name == ""}) { // I don't want you to be able to drag my blank row. That's supposed to be at the bottom.
//            return false
//        }
//        else {
            return true
//        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = itemPantryInstance.items[fromIndexPath.row]
        itemPantryInstance.items.remove(at: fromIndexPath.row)
        itemPantryInstance.items.insert(itemToMove, at: to.row)
        if to.row == itemPantryInstance.items.count - 1 { // When you move an item below the new item initialize slot, delete and recreate the blanks.
            // Possibly a little excessive; I could likely hard code deleting "second to last" instead of "all blanks"
            itemPantryInstance.items = itemPantryInstance.items.filter{$0.name != ""}
            itemPantryInstance.items.append(Item(name: "", checked: false, price: 0))
            self.tableView.reloadData()
        }
    }
    
    
    //MARK: NSCoding
    
    private func loadItems() -> [Item]? { // Attempts to load saved pantry items, but only those that are not blank.
        print("Loading pantry items.")
        var fullPantry = NSKeyedUnarchiver.unarchiveObject(withFile: Item.PantryArchiveURL.path) as? [Item]
        fullPantry?.append(Item(name: "", checked: false, price: 0))
        return fullPantry
    }
    
    func saveItems() {
        // Only the items that aren't blank get saved to file.
        itemPantryInstance.items = itemPantryInstance.items.filter{$0.name != ""}
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(itemPantryInstance.items, toFile: Item.PantryArchiveURL.path)
        print(itemPantryInstance.items)
        if isSuccessfulSave {
            os_log("Entire pantry successfully saved.", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save pantry.", log: OSLog.default, type: .error)
        }
    }
    
    
    //MARK: Refresh Page
    
    func refreshPage() {
        print("REFRESH PANTRY")
        itemPantryInstance.items = itemPantryInstance.items.filter{$0.name != ""}
        itemPantryInstance.items.append(Item(name: "", checked: false, price: 0))
        tableView.reloadData()
    }
    
    
    func loadDefaults() {
        print("No pantry items saved, loading defaults.")
        let instruction1 = Item(name: "You don't have any items yet", checked: false, price: 0)
        let instruction2 = Item(name: "Add things here!", checked: false, price: 0)
        itemPantryInstance.items = [instruction1, instruction2]
        refreshPage() // Add extra row.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
