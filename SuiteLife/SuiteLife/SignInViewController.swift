//
//  SignInViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/19/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Pastel
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
      
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Automatically sign in the user
        GIDSignIn.sharedInstance().signInSilently()
        
        // UI Button configuration
        
        signInButton.style = .wide
        
        // Pastel
        
        // Pastel Background
        let pastelView = PastelView(frame: view.bounds)
        
        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        
        // Custom Duration
        pastelView.animationDuration = 7.0
        
        // Custom Color
        pastelView.setColors([UIColor(red: 0/255, green: 195/255,  blue: 255/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 255/255,  blue: 28/255, alpha: 1.0),
                              UIColor(red: 0/255, green: 195/255,  blue: 255/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 255/255,  blue: 28/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
        
    }
    
    // Runs when the device rotates.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            
            // Remove the bottom subview, which is at this point pastelView.
            for view in self.view.subviews {
                view.removeFromSuperview()
                break
            }
            
            // Run viewDidLoad to add a new pastelView with the new screen dimensions.
            self.viewDidLoad()
        }
    }
    

}
