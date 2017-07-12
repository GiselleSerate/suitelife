//
//  NewAccountViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 7/10/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Firebase

class NewAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var handleField: UITextField!
    @IBOutlet weak var finishButton: UIButton!
    
    let currentUserID = Auth.auth().currentUser!.uid
    
    let databaseRef = Database.database().reference()
    
    var errors: [String: Bool] = ["length": false, "unique": false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.delegate = self
        handleField.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func finishButtonPressed(_ sender: UIButton) { // Assume there are errors until proven otherwise.
        errors["length"] = true
        errors["unique"] = true
        
        if (nameField.text?.characters.count ?? 0 >= 3) || (nameField.text?.characters.count ?? 0 >= 3)  {
            errors["length"] = false
        }
        
        databaseRef.child("users").queryOrdered(byChild: "handle").queryEqual(toValue: handleField.text).observeSingleEvent(of: .value, with: {(snapshot) in
            // If the property is taken, do not allow saving.
            self.errors["unique"] = snapshot.exists()
            
            // Done with callback, continue saving.
            self.finishAccountCreation()
        })
    }

    private func finishAccountCreation() {
        if !errors["length"]! && !errors["unique"]! {
            // Save to firebase.
            databaseRef.child("users/\(currentUserID)/name").setValue(nameField.text!)
            databaseRef.child("users/\(currentUserID)/handle").setValue(handleField.text!)
            databaseRef.child("users/\(currentUserID)/searchFields/name").setValue(nameField.text!.lowercased())
            databaseRef.child("users/\(currentUserID)/searchFields/handle").setValue(handleField.text!.lowercased())
            
            // TODO: Bandaid fix for #62: Initialize pantry automagically.
            // Initialize pantry with a default item. Code for list not necessary, as the list always loads first.
            let newPantry: [[String:Any]] = [Item(name: "Add items to your pantry here!", checked: false, price: 0).toDict() as! Dictionary<String, Any>]
            databaseRef.child("users/\(currentUserID)/pantry").setValue(newPantry)
            let newList: [[String:Any]] = [Item(name: "Add items to your list here!", checked: false, price: 0).toDict() as! Dictionary<String, Any>]
            databaseRef.child("users/\(currentUserID)/list").setValue(newList)
            
            let tabController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
            // Transition to the tab controller from the sign-in
            UIApplication.shared.keyWindow?.rootViewController = tabController
        }
        else {
            var errMessage = ""
            if errors["length"]! {
                errMessage += "Name and handle must be 3 characters or longer."
            }
            if errors["unique"]! {
                errMessage += "\nHandle must be unique."
            }
            let alert = UIAlertController(title: "Invalid Name or Handle", message: errMessage, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
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
