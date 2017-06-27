//
//  ListPantryTabViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/14/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import PureLayout

class ListPantryTabViewController: TabmanViewController, PageboyViewControllerDataSource {

    var tabViewControllers: [UIViewController]?
    
    override func viewDidLoad() {
        print("CALLED VIEWDIDLOAD")
        super.viewDidLoad()
        
        // Tabman setup
        
        self.dataSource = self
        self.bar.location = .bottom
        
        recalculateBarLocation()
    }
    
    
    // Runs when the device rotates.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("DEVICE ROTATED")
        coordinator.animate(alongsideTransition: nil) { _ in
            // Run viewDidLoad to recalibrate the screensize.
            self.viewDidLoad()
        }
    }

    //MARK: Tabman
    func viewControllers(forPageboyViewController pageboyViewController: PageboyViewController) -> [UIViewController]? {
        if let viewCons = self.tabViewControllers {
            // If the view controllers already exist, return them
            print("returning view cons")
            return viewCons
        } else { // TODO: investigate if the else case is what's making this buggy
            print("returning NEW view cons")
            // Create the view controllers and add them to an array
            let viewCon1 = self.newViewController(name: "List")
            let viewCon2 = self.newViewController(name: "Pantry")
            self.bar.items = [TabmanBar.Item(title: "List"), TabmanBar.Item(title: "Pantry")]
            self.tabViewControllers = [viewCon1, viewCon2]
            return self.tabViewControllers
        }
        
        
//        if let viewCons = self.tabViewControllers {
//            // If the view controllers already exist, return them
//            print("returning view cons")
//            return viewCons
//        } else { // TODO: investigate if the else case is what's making this buggy
//            // Create the view controllers and add them to an array
//            let viewCon1 = self.newViewController(name: "List")
//            let viewCon2 = self.newViewController(name: "Pantry")
//            self.bar.items = [TabmanBar.Item(title: "List"), TabmanBar.Item(title: "Pantry")]
//            self.tabViewControllers = [viewCon1, viewCon2]
//            return self.tabViewControllers
//        }
    }

    
    func defaultPageIndex(forPageboyViewController pageboyViewController: PageboyViewController) -> PageboyViewController.PageIndex? {
        return .first
    }
    
    //MARK: Helper methods
    
    private func newViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(name)NavTableViewController")
    }
    
    private func recalculateBarLocation() {
        // Get font sizing.
        let font = UIFont.systemFont(ofSize: 16)
        let fontAttributes = [NSFontAttributeName: font] // it says name, but a UIFont works
        let myText = "PantryList"
        let tabmanWidth = (myText as NSString).size(attributes: fontAttributes)
        
        // Set offset using font sizing.
        let offset = (view.bounds.maxX-tabmanWidth.width-40)/2
        print("The width of the view is \(view.bounds.maxX)")
        
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            appearance.layout.edgeInset = offset
        })
    }
    

}
