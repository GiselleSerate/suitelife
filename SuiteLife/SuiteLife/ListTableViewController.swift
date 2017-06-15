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
        print("the view is going to disappear")
        super.viewWillDisappear(true)
        saveItems()
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
        let item = items[indexPath.row]
        
        if item.name != "" {
            cell.attachNameLabel(&item.name)
            cell.attachSelectButton(&item.checked)
            cell.controller = self
        }
        return cell
    }
    
    
    //MARK: Text Field Delegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Adding a new item.")
        items.append(Item(name: textField.text!, checked: false, isListItem: true)!)
    }
    
    private func loadItems() -> [Item]? {
        print("Attempting to load saved list items.")
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.ListArchiveURL.path) as? [Item] // If it finds something, it will give you an array of items.
    }
    
    private func saveItems() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ListArchiveURL.path)
        if isSuccessfulSave {
            os_log("ENTIRE list successfully saved.", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save list.", log: OSLog.default, type: .error)
        }
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            items.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
 
    
    // TODO: Doesn't do anything currently.
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        
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
