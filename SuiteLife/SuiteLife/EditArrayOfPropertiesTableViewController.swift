//
//  EditArrayOfPropertiesTableViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/28/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Firebase

class EditArrayOfPropertiesTableViewController: UITableViewController, UITextFieldDelegate {
    
    private var textField: UITextField?
    
    let textCellIdentifier = "EditArrayOfPropertiesTextInputCell"
    let cellIdentifier = "EditArrayOfPropertiesCell"
    
    private var propertyName: String?
    private var propertyKey: String?
    private let databaseRef = Database.database().reference()
    let userID = Auth.auth().currentUser!.uid
    
    private var propertyArray: [String]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = propertyName!
        
        // populate the first section with the static cell
        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)

        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadPropertyArray()
    }
    
    // bandaid function used in place of an initializer since setting up one was hard
    func setProperty(propertyKey: String, propertyName: String) {
        self.propertyKey = propertyKey
        self.propertyName = propertyName
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Section 1 is the text input, Section 2 is dynamic
        if propertyArray != nil {
            return 2
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            if let arr = self.propertyArray {
                return arr.count
            }
            // if the property array doesn't exist, then there must be no rows
            return 0
        default:
            fatalError("Invalid section number \(section)")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            // No configuration required for the input cell
            let cell = tableView.dequeueReusableCell(withIdentifier: self.textCellIdentifier, for: indexPath) as! EditArrayOfPropertiesTextInputTableViewCell
            if self.textField == nil {
                // get a reference to the input text field
                // and configure it
                self.textField = cell.textField
                self.textField!.placeholder = "Add \(propertyName!)"
                self.textField!.delegate = self
                self.textField!.returnKeyType = .done
            }
            return cell
        case 1:
            // Configure property array cells
            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! EditArrayOfPropertiesTableViewCell
            cell.nameLabel.text = propertyArray![indexPath.row]
            return cell
        default:
            fatalError("Invalid section \(indexPath.section)")
        }

    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            // The text input field should not be editable
            return false
        case 1:
            // Sure, you can edit the property array cells
            return true
        default:
            fatalError("Invalid section \(indexPath.section)")
        }
        // somehow if it falls through here return false
        return false
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // If we're able to delete the row, this means we're editing the section section, so don't bother checking
            // Delete the row from the data source
            propertyArray?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // If we somehow get here, add the empty string
            propertyArray?.append("")
            tableView.insertRows(at: [indexPath], with: .automatic)
        }    
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.section {
        case 0:
            // The text input field should not be editable
            return false
        case 1:
            // Sure, you can edit the property array cells
            return true
        default:
            fatalError("Invalid section \(indexPath.section)")
        }
        // somehow if it falls through here return false
        return false
    }
    
    //MARK: Private Methods
    
    private func loadPropertyArray() {
        self.databaseRef.child("users/\(userID)/\(propertyKey!)").observeSingleEvent(of: .value, with: {(snapshot) in
            // We're assuming for now that all of these properties are strings
            self.propertyArray = snapshot.value as? Array
            self.tableView.reloadData()
            if self.propertyArray != nil {
                print("Loaded property array with key: \(self.propertyKey!).")
            }
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    // MARK: TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            if self.propertyArray != nil {
                // the array already exists, so just add a new to the top and add text to it
                self.propertyArray!.insert(text, at: 0)
                // subtract 1 from the array count to make sure we add the right number of rows
                self.tableView.insertRows(at: [IndexPath(row: propertyArray!.count - 1, section: 1)], with: .automatic)
                self.tableView.reloadData()
            }
            else {
                // the array doesn't exist yet, so create it
                self.propertyArray = [text]
                self.tableView.insertSections(IndexSet(integer: 1), with: .automatic)
                //self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
                self.tableView.reloadData()
            }
            // Clear the text field
            textField.text = ""
        }
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Saving
    
    @IBAction func saveChanges(withSender sender: UIBarButtonItem){
        print("Save button pressed")
        // Set the value corresponding to the user's ID and the value of propertyArray
        if let arr = self.propertyArray {
        self.databaseRef.child("users/\(userID)/\(propertyKey!)").setValue(arr as NSArray)
            print("Saved property \(propertyKey!)")
        }
        self.exitView()
    }
    
    // MARK: Private Methods
    
    private func exitView() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }

}
