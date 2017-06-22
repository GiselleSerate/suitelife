//
//  SignInViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/19/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Pastel

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var signInButton: GIDSignInButton!
    
    var ptr: UnsafeMutablePointer<PastelView>?
    
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
        ptr?.pointee = pastelView
        
        // Custom Direction
        pastelView.startPastelPoint = .bottomLeft
        pastelView.endPastelPoint = .topRight
        
        // Custom Duration
        pastelView.animationDuration = 3.0
        
        // Custom Color
        pastelView.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            
            // FORCE STOP ANIMATION
            for view in self.view.subviews {
                print("remove only one")
                view.removeFromSuperview()
                break
            }
            
            self.viewDidLoad()
        }
    }

}
