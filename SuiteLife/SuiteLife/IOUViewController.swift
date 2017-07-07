//
//  IOUViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/22/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Firebase

class IOUViewController: UITableViewController {
    
    let databaseRef = Database.database().reference()

    var ious: [UserWithCash] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadIOUs()

        // Handle pull to refresh.
        self.refreshControl?.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Refresh
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        print("Calling handleRefresh.")
        loadIOUs()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    //MARK: TableViewController Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // There's only one section.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of rows is equal to the number of items.
        return ious.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(ious)
        // Dequeue the cell...
        let cellIdentifier = "IOUTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? IOUTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of IOUTableViewCell.")
        }
         
        // Configure the cell...
        var item = ious[indexPath.row]
        cell.attachUser(&item)
        cell.controller = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Pay back \(self.ious[indexPath.row].name)", message: "Enter an amount that YOU have paid TO this person.", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.text = "Price Here"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default , handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            // TODO: VALIDATION PLEASE WE WANT PRICES
            DebtHelper.recordPersonalDebts(debtDict: [self.ious[indexPath.row].userID: (textField?.text as! NSString).integerValue * -1], onCompletion: self.tableView.reloadData) // It's dying here because of casting.
            // TODO: Reload after this. 
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Firebase
    
    func loadIOUs() { // Loads IOUs into the data structure in this class.
        databaseRef.child("users/\(Auth.auth().currentUser!.uid)/debts").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                if let childRef = child as? DataSnapshot {
                    self.setDBVals(userID: childRef.key, balance: (childRef.value as? Int)!) // Set each person's balances.
                }
            }
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    func setDBVals(userID: String, balance: Int) { // Get name and handle from DB and populate ious.
        if let userIndex = ious.index(where: {$0.userID == userID}) { // Already contains this person.
            ious[userIndex].balance = balance
        }
        else {
            databaseRef.child("users/\(userID)").observeSingleEvent(of: .value, with: {(snapshot) in
                if let childRef = snapshot as? DataSnapshot {
                    let name = childRef.childSnapshot(forPath: "name").value as! String
                    let handle = childRef.childSnapshot(forPath: "handle").value as! String
                    self.ious.append(UserWithCash(name: name, handle: handle, userID: userID, balance: balance))
                }
                self.tableView.reloadData()
            }) {(error) in
                print(error.localizedDescription)
            }
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
