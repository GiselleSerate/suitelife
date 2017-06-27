//
//  IOUViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/22/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit

class IOUViewController: UITableViewController {
    
    // Test users for display purposes.
    var testUserDB = [User(name: "Giselle", handle: "@gserate", balance: 1200), User(name: "Cole", handle: "@ckurashige", balance: 362), User(name: "Jeni", handle: "@jzhu", balance: -869)]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
        return testUserDB.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue the cell...
        let cellIdentifier = "IOUTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? IOUTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of IOUTableViewCell.")
        }
        
        // Configure the cell...
        var item = testUserDB[indexPath.row]
        cell.attachUser(&item)
        cell.controller = self
        return cell
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
