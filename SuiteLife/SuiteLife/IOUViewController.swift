//
//  IOUViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/22/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Firebase

class IOUViewController: UITableViewController, UITextFieldDelegate {
    
    var alert: UIAlertView = UIAlertView(title: "Loading Your Items", message: "Please Wait...", delegate: nil, cancelButtonTitle: nil);
    
    let databaseRef = Database.database().reference()

    var ious: [Int:[UserWithCash]] = [0:[], 1:[], 2:[]] // Dictionary of index and people.

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
        // There is a section for each group of people.
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The number of rows is equal to the number of items.
        return ious[section]!.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(ious)
        // Dequeue the cell...
        let cellIdentifier = "IOUTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? IOUTableViewCell
            else {
                fatalError("The dequeued cell is not an instance of IOUTableViewCell.")
        }
        
        var item = ious[indexPath.section]?[indexPath.row]
        cell.attachUser(&item!, sign: indexPath.section)
        cell.controller = self

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: // I owe money.
            return "People You Owe"
        case 1: // I am owed money.
            return "People Who Owe You"
        default: // No money is owed and I don't care.
            return "Settled Up"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Pay back \(self.ious[indexPath.section]![indexPath.row].name)", message: "Enter an amount that YOU have paid TO this person.", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            
//            textField.addTarget(self, action: #selector(didChangeValue(_:)), for: .editingChanged)
//            
//            let newText = textField.text?.replacingCharacters(in: range, with: string)
            
            textField.delegate = self
            textField.placeholder = "Price Here"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default , handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            // TODO: VALIDATION PLEASE WE WANT PRICES
            DebtHelper.recordPersonalDebts(debtDict: [(self.ious[indexPath.section]?[indexPath.row].userID)!: PriceHelper.cleanPrice(price: textField?.text) * -1], onCompletion: self.tableView.reloadData)
            self.ious[indexPath.section]?.remove(at: indexPath.row)
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    // I don't know if this gonna work.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return PriceHelper.validatePrice(price: string, alreadyText: textField.text!)
    }
    
    
    // MARK: Firebase
    
    func loadIOUs() { // Loads IOUs into the data structure in this class.
        databaseRef.child("users/\(Auth.auth().currentUser!.uid)/debts").observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                if let childRef = child as? DataSnapshot {
                    self.setDBVals(userID: childRef.key, balance: (childRef.value as? Int)!) // Set each person's balances
                }
            }
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    func setDBVals(userID: String, balance: Int) { // Get name and handle from DB and populate ious.
        // TODO: IM REALLY SORRY ABOUT ALL OF THIS CODE
        if let userIndex = ious[0]?.index(where: {$0.userID == userID}) { // Already contains this person.
            ious[0]?[userIndex].balance = balance
        }
        else if let userIndex = ious[1]?.index(where: {$0.userID == userID}) { // Already contains this person.
            ious[1]?[userIndex].balance = balance
        }
        else if let userIndex = ious[2]?.index(where: {$0.userID == userID}) { // Already contains this person.
            ious[2]?[userIndex].balance = balance
        }
        else {
            databaseRef.child("users/\(userID)").observeSingleEvent(of: .value, with: {(snapshot) in
                if let childRef = snapshot as? DataSnapshot {
                    let name = childRef.childSnapshot(forPath: "name").value as! String
                    let handle = childRef.childSnapshot(forPath: "handle").value as! String
                    var oweDir = 0 // Default, you owe them money.
                    if balance == 0 { // Neutral.
                        oweDir = 2
                    }
                    else if balance < 0 { // They owe you money.
                        oweDir = 1
                    }
                    
                    self.ious[oweDir]!.append(UserWithCash(name: name, handle: handle, userID: userID, balance: balance))
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
