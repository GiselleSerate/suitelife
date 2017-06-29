//
//  EditSinglePropertyTableViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/26/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Firebase

class EditSinglePropertyTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private var propertyName: String?
    private var propertyKey: String?
    private let databaseRef = Database.database().reference()
    
    let userID = Auth.auth().currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = propertyName!
        
        self.textField.placeholder = "Set \(propertyName!)"
        self.textField.delegate = self
        self.textField.returnKeyType = .done
        
        determineSaveButtonState()
        
        populateTextField()
    }
    
    // bandaid function used in place of an initializer since setting up one was hard
    func setProperty(propertyKey: String, propertyName: String) {
        self.propertyKey = propertyKey
        self.propertyName = propertyName
    }

    // MARK: - Table view data source
    // This table view will only ever have 1 section and 1 row since it's meant for editing one property
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // MARK: Editing and Saving


    @IBAction func cancelEditing(sender: UIBarButtonItem) {
        print("Cancel button pressed")
        self.exitView()
    }
    
    @IBAction func saveChanges(sender: UIBarButtonItem) {
        print("Save button pressed")
        // Set the value corresponding to the user's ID and the cell's name
        self.databaseRef.child("users/\(userID)/\(propertyKey!)").setValue(textField.text)
        print("Saved property \(propertyKey!) with value \(textField.text ?? "")")
        self.exitView()
    }
    
    // MARK: TextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        determineSaveButtonState()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Private Methods
    
    private func populateTextField() {
        // Get the value
        self.databaseRef.child("users/\(userID)/\(propertyKey!)").observeSingleEvent(of: .value, with: {(snapshot) in
            // We're assuming for now that all of these properties are strings
            let propertyValue = snapshot.value as? String
            self.textField.text = propertyValue
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    private func determineSaveButtonState() {
        if textField.text == "" {
            // Don't allow saving unless the text field is nonempty
            self.saveButton?.isEnabled = false
        } else {
            self.saveButton?.isEnabled = true
        }
    }
    
    private func exitView() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }
}
