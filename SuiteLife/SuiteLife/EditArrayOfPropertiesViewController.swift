//
//  EditArrayOfPropertiesViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/28/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Firebase

class EditArrayOfPropertiesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentifier = "EditArrayOfPropertiesCell"
    
    private var propertyName: String?
    private var propertyKey: String?
    private let databaseRef = Database.database().reference()
    let userID = Auth.auth().currentUser!.uid
    
    private var propertyArray: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = propertyName!
        
        self.textField.delegate = self
        self.textField.placeholder = "Add \(propertyName!)"
        self.textField.returnKeyType = .done
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
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
    
    
    // MARK: Table View Data Source

    func numberOfSections(in tableView: UITableView) -> Int {
        // Only one section
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.propertyArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        cell.textLabel?.text = propertyArray[indexPath.row]
        return cell
    }

    // Support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            propertyArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // Support rearranging the table view.
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }

    // Support conditional rearranging of the table view.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.tableView.setEditing(editing, animated: animated)
    }
    
    
    //MARK: Private Methods
    
    private func loadPropertyArray() {
        self.databaseRef.child("users/\(userID)/\(propertyKey!)").observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
            // We're assuming for now that all of these properties are strings
            if let databaseArray = snapshot.value as? NSArray {
                self.propertyArray = databaseArray as! Array
                self.tableView.reloadData()
                print("Loaded property array with key: \(self.propertyKey!).")
            }

        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            self.propertyArray.insert(text, at: 0)
            // subtract 1 from the array count to make sure we add the right number of rows
            self.tableView.insertRows(at: [IndexPath(row: propertyArray.count - 1, section: 0)], with: .automatic)
            self.tableView.reloadData()
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
        self.databaseRef.child("users/\(userID)/\(propertyKey!)").setValue(self.propertyArray as NSArray)
            print("Saved property \(propertyKey!)")
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
