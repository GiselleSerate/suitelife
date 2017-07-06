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
    
    // MARK: Properties and Outlets
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentifier = "EditArrayOfPropertiesCell"
    
    private var propertyName: String?
    private var propertyKey: String?
    private let databaseRef = Database.database().reference()
    let currentUserID = Auth.auth().currentUser!.uid
    
    private var propertyArray: [String] = []
    
    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = propertyName!
        
        // Configure textField
        textField.delegate = self
        textField.placeholder = "Add \(propertyName!)"
        textField.returnKeyType = .done
        
        // Configure tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        navigationItem.leftBarButtonItem = editButtonItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload the property array whenever the view will appear.
        loadPropertyArray()
    }
    
    
    // MARK: UITableViewDataSource and UITableViewDelegate

    func numberOfSections(in tableView: UITableView) -> Int {
        // Only one section.
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return propertyArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        // Label the text with whatever is in the property array at that row.
        cell.textLabel?.text = propertyArray[indexPath.row]
        return cell
    }

    // Allow all rows to be edited.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source and Table View.
            propertyArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // Support rearranging the table view.
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {}

    // Allow all rows to be rearranged.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Make the edit button work.
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    // MARK: TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            propertyArray.insert(text, at: 0)
            // Subtract 1 from the array count to make sure we add the right number of rows.
            tableView.insertRows(at: [IndexPath(row: propertyArray.count - 1, section: 0)], with: .automatic)
            tableView.reloadData()
            // Clear the text field.
            textField.text = ""
        }
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Saving
    
    @IBAction func saveChanges(withSender sender: UIBarButtonItem){
        print("Save button pressed")
        // Set the value corresponding to the user's ID and the value of propertyArray.
        databaseRef.child("users/\(currentUserID)/\(propertyKey!)").setValue(self.propertyArray as NSArray)
        print("Saved property \(propertyKey!)")
        exitView()
    }
    
    
    // MARK: Private Methods
    
    private func loadPropertyArray() {
        databaseRef.child("users/\(currentUserID)/\(propertyKey!)").observeSingleEvent(of: .value, with: { (snapshot:DataSnapshot) in
            // Try to retrieve the property array from the database.
            if let databaseArray = snapshot.value as? NSArray {
                self.propertyArray = databaseArray as! Array
                self.tableView.reloadData()
                print("Loaded property array with key: \(self.propertyKey!).")
            }
            
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    private func exitView() {
        // Custom transition.
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: Public Methods
    
    // Bandaid function used in place of an initializer since setting up one was hard...
    func setProperty(propertyKey: String, propertyName: String) {
        self.propertyKey = propertyKey
        self.propertyName = propertyName
    }

}
