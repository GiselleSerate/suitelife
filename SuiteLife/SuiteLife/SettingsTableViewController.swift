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
    static let rowsPerSection = [4,1]
    
    @IBAction func signOutButtonPressed(_ sender: Any) {
        // Sign out from Google
        GIDSignIn.sharedInstance().signOut()
        let signInController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController")
        // Transition to the sign in view controller
        UIApplication.shared.keyWindow?.rootViewController = signInController
    }
    
    //MARK: Edit Single Properties

    @IBAction func editLocation(_ sender: Any) {
        print("Location pressed")
        let locationEditor = getSinglePropertyEditor()
        locationEditor.setProperty(propertyKey: "location", propertyName: "Location")
        let navController = UINavigationController(rootViewController: locationEditor)
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func editDisplayName(_ sender: Any) {
        print("Display name pressed")
        let displayNameEditor = getSinglePropertyEditor()
        displayNameEditor.setProperty(propertyKey: "displayName", propertyName: "Display Name")
        let navController = UINavigationController(rootViewController: displayNameEditor)
        self.present(navController, animated: true, completion: nil)
    }
    
    @IBAction func editDietaryRestrictions(_ sender: Any) {
        print("Dietary Restrictions pressed")
        let dietaryRestrictionsEditor = getArrayOfPropertiesEditor()
        dietaryRestrictionsEditor.setProperty(propertyKey: "dietaryRestrictions", propertyName: "Dietary Restrictions")
        let navController = UINavigationController(rootViewController: dietaryRestrictionsEditor)
        self.present(navController, animated: true, completion: nil)
    }
    
    //MARK: Private Methods
    
    private func getSinglePropertyEditor() -> EditSinglePropertyTableViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditSinglePropertyTableViewController") as! EditSinglePropertyTableViewController
    }
    private func getArrayOfPropertiesEditor() -> EditArrayOfPropertiesTableViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EditArrayOfPropertiesTableViewController") as! EditArrayOfPropertiesTableViewController
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
