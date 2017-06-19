//
//  ListTableViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/14/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import os.log

class ListTableViewController: ItemTableViewController, UITextFieldDelegate {
    

    override func viewDidLoad() {
        
        navigationItem.leftBarButtonItem = editButtonItem

        super.viewDidLoad()
        if let savedItems = loadItems() { // If we actually do have some file of items to load.
            items += savedItems
        }
        else {
            loadDefaults()
        }
        

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("The view is going to disappear.")
        saveItems()
        super.viewWillDisappear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    //MARK: Display
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ListTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ListTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of ListTableViewCell.")
        }
        
        // Configure the cell...
        var item = items[indexPath.row]
        cell.attachItem(&item)
        cell.controller = self
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert { // Possibly I could have implemented this instead of writing my own thing.
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.row == items.index(where: {$0.name == ""}) { // I don't want you to be able to drag my blank row. That's supposed to be at the bottom.
            return false
        }
        else {
            return true
        }
    }
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = items[fromIndexPath.row]
        items.remove(at: fromIndexPath.row)
        items.insert(itemToMove, at: to.row)
        if to.row == items.count - 1 { // When you move an item below the new item initialize slot, delete and recreate the blanks.
            // Possibly a little excessive; I could likely hard code deleting "second to last" instead of "all blanks"
            items = items.filter{$0.name != ""}
            items.append(Item(name: "", checked: false, price: 0))
            self.tableView.reloadData()
        }
    }
    
    
    //MARK: NSCoding
    
    private func loadItems() -> [Item]? { // Attempts to load saved list items, but only those that are not blank.
        var fullList = NSKeyedUnarchiver.unarchiveObject(withFile: Item.ListArchiveURL.path) as? [Item]
        fullList?.append(Item(name: "", checked: false, price: 0))
        return fullList
    }
    
    private func saveItems() {
        // Only the items that aren't blank get saved to file.
        items = items.filter{$0.name != ""}
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ListArchiveURL.path)
        print(items)
        if isSuccessfulSave {
            os_log("Entire list successfully saved.", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save list.", log: OSLog.default, type: .error)
        }
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
