//
//  ListTableViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/14/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import os.log

class ListTableViewController: ItemTableViewController {
    

    override func viewDidLoad() {
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
        super.viewWillDisappear(true)
        print("THE VIEW IS DISAPPEARIN")
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
        
        cell.nameLabel.text = item.name
        cell.selectButton.isOn = item.checked
        
        return cell
    }
    
    private func loadItems() -> [Item]? {
        print("Attempting to load saved list items.")
        return NSKeyedUnarchiver.unarchiveObject(withFile: Item.ListArchiveURL.path) as? [Item] // If it finds something, it will give you an array of items.
    }
    
    private func saveItems() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(items, toFile: Item.ListArchiveURL.path)
        if isSuccessfulSave {
            os_log("List successfully saved.", log: OSLog.default, type: .debug)
            print(loadItems())
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
