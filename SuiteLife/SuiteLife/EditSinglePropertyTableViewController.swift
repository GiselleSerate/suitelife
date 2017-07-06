//
//  EditSinglePropertyViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/26/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Firebase

class EditSinglePropertyViewController: UIViewController, UITextFieldDelegate {

    // MARK: Outlets and Properties
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    private var propertyName: String?
    private var propertyKey: String?
    // Must the property be unique in the database?
    private var uniqueRequired: Bool?
    // Do we create a searchable field for the property?
    private var searchable: Bool?
    private let databaseRef = Database.database().reference()
    private let currentUserID = Auth.auth().currentUser!.uid
    
    //MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = propertyName!
        
        self.textField.placeholder = "Set \(propertyName!)"
        self.textField.delegate = self
        self.textField.returnKeyType = .done
        
        determineSaveButtonState()
        
        populateTextField()
    }
    
    // MARK: IBActions

    @IBAction func cancelEditing(sender: UIBarButtonItem) {
        print("Cancel button pressed")
        exitView()
    }
    
    @IBAction func saveChanges(sender: UIBarButtonItem) {
        print("Save button pressed")
        // Set the value corresponding to the user's ID and the cell's name
        databaseRef.child("users/\(currentUserID)/\(propertyKey!)").setValue(textField.text)
        print("Saved property \(propertyKey!) with value \(textField.text ?? "")")
        
        // If the property is searchable, create a lowercase variant and put it under the searchFields node
        if searchable! {
            let childRef = databaseRef.child("users/\(currentUserID)/searchFields/\(propertyKey!)")
            childRef.setValue(textField.text?.lowercased())
        }
        exitView()
    }
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
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
        databaseRef.child("users/\(currentUserID)/\(propertyKey!)").observeSingleEvent(of: .value, with: {(snapshot) in
            // All properties must be strings.
            let propertyValue = snapshot.value as? String
            self.textField.text = propertyValue
        }) {(error) in
            print(error.localizedDescription)
        }
    }
    
    private func determineSaveButtonState() {
        // Check if the property must be unique and if the textfield has text in it.
        if (uniqueRequired!) && (textField.text != nil) {
            // Disable saving, which means users must wait for the callback (and it must be successful) to save.
            self.saveButton?.isEnabled = false
            let usersRef = databaseRef.child("users")
            // Query to see if any user has this property already.
            usersRef.queryOrdered(byChild: propertyKey!).queryEqual(toValue: textField.text).observeSingleEvent(of: .value, with: {(snapshot) in
                // If the property is taken, disable the save button.
                self.saveButton.isEnabled = !snapshot.exists()
                // Enable the save button if the property is taken by the current user.
                for child in snapshot.children {
                    if let childRef = child as? DataSnapshot {
                        // Check if the current user ID is equal to the ID of the user trying to save the current property.
                        self.saveButton?.isEnabled = (self.currentUserID == childRef.key)
                    }
                }
            })
        // If we get here, it must not be required that the property be unique, so if there is text in the box, we can allow saving.
        } else if textField.text != nil {
            saveButton?.isEnabled = true
        } else {
            saveButton?.isEnabled = false
        }
    }
    
    private func exitView() {
        // Custom transition
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        dismiss(animated: false, completion: nil)
    }
    
    // MARK: Public Methods
    
    // Bandaid function used in place of an initializer since setting up one was hard...
    func setProperty(propertyKey: String, propertyName: String, unique isUnique: Bool, searchable: Bool) {
        self.propertyKey = propertyKey
        self.propertyName = propertyName
        self.uniqueRequired = isUnique
        self.searchable = searchable
    }
}
