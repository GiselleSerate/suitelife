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
    
    // Test users for display purposes.
//    var testUserDB = [UserWithCash(name: "Giselle", handle: "@gserate", balance: 1200), UserWithCash(name: "Cole", handle: "@ckurashige", balance: 362), UserWithCash(name: "Jeni", handle: "@jzhu", balance: -869)]

    var ious: [UserWithCash] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        loadIOUs()
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
