//
//  SignInViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/19/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up Google Single Sign-In

        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Automatically sign in the user
        GIDSignIn.sharedInstance().signInSilently()
        
        // UI Button configuration
        
        signInButton.style = .wide
    }

}
