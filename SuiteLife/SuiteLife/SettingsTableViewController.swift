//
//  SettingsTableViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/19/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import GoogleSignIn

class SettingsTableViewController: UITableViewController {
    
    //MARK: Properties
    
    //TODO: hardcode to correspond to the actual number of sections we end up with
    static let rowsPerSection = [6,1]
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        // Sign out from Google
        GIDSignIn.sharedInstance().signOut()
        let signInController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController")
        // Transition to the sign in view controller
        UIApplication.shared.keyWindow?.rootViewController = signInController
    }
    
    //MARK: IBActions

    @IBAction func editLocation(_ sender: Any) {
        print("Location pressed")
        let locationEditor = getSinglePropertyEditor()
        locationEditor.setProperty(propertyKey: "location", propertyName: "Location", unique: false, searchable: false)
        let navController = UINavigationController(rootViewController: locationEditor)
        presentViewController(navController)
    }
    
    @IBAction func editName(_ sender: Any) {
        print("Name pressed")
        let nameEditor = getSinglePropertyEditor()
        nameEditor.setProperty(propertyKey: "name", propertyName: "Name", unique: false, searchable: true)
        let navController = UINavigationController(rootViewController: nameEditor)
        presentViewController(navController)
    }
    
    @IBAction func editHandle(_ sender: Any) {
        print("Handle pressed")
        let handleEditor = getSinglePropertyEditor()
        handleEditor.setProperty(propertyKey: "handle", propertyName: "Handle", unique: true, searchable: true)
        let navController = UINavigationController(rootViewController: handleEditor)
        presentViewController(navController)
    }
    
    @IBAction func editDietaryRestrictions(_ sender: Any) {
        print("Dietary Restrictions pressed")
        let dietaryRestrictionsEditor = getArrayOfPropertiesEditor()
        dietaryRestrictionsEditor.setProperty(propertyKey: "dietaryRestrictions", propertyName: "Dietary Restrictions")
        let navController = UINavigationController(rootViewController: dietaryRestrictionsEditor)
        presentViewController(navController)
    }
    
    @IBAction func editGroups(_ sender: Any) {
        print("Groups pressed")
        let groupsEditor = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GroupsViewController") as! GroupsViewController
        let navController = UINavigationController(rootViewController: groupsEditor)
        presentViewController(navController)
    }
    
    //MARK: Private Methods
    
    private func getSinglePropertyEditor() -> EditSinglePropertyViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditSinglePropertyViewController") as! EditSinglePropertyViewController
    }
    private func getArrayOfPropertiesEditor() -> EditArrayOfPropertiesViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditArrayOfPropertiesViewController") as! EditArrayOfPropertiesViewController
    }
    
    private func presentViewController(_ viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        present(viewController, animated: false, completion: nil)
    }
    
    // MARK: - Table view data source
    
    // This is a STATIC table, so we only need to implement the number of sections and rows in them

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsTableViewController.rowsPerSection.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsTableViewController.rowsPerSection[section]
    }

}
