//
//  AppDelegate.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/12/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var ref: DatabaseReference!
    
    var window: UIWindow?
    
    //MARK: Default Methods
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        ref = Database.database().reference()
        

        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //MARK: Google Sign-In Implementation
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil {
            // Do something for the signed in user here.
            guard let authentication = user.authentication else {
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { (user, error) in
                if error == nil {
                    let tabController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
                    // Transition to the tab controller from the sign-in
                    UIApplication.shared.keyWindow?.rootViewController = tabController
                    print("Here is the Auth id \(Auth.auth().currentUser?.uid)")
                    print("Here is the GID id \(GIDSignIn.sharedInstance().currentUser.userID)")
                }
            }
        } else {
            print("\(error.localizedDescription)")
        }
    }


    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Do something when the user disconnects from the app here
    }

    

}

