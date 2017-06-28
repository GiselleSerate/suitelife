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
        super.viewDidLoad()
        
        // Tabman setup
        
        self.dataSource = self
        self.bar.location = .bottom
        
        recalculateBarLocation()
    }
    
    
    // Runs when the device rotates.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil) { _ in
            // Run viewDidLoad to recalibrate the screensize.
            self.viewDidLoad()
        }
    }

    //MARK: Tabman
    func viewControllers(forPageboyViewController pageboyViewController: PageboyViewController) -> [UIViewController]? {
        if let viewCons = self.tabViewControllers { // If the view controllers already exist, return them

            return viewCons
        } else { // Create the view controllers and add them to an array
            let navCon1 = self.newViewController(name: "List")
            let viewCon1 = navCon1.childViewControllers[0] as! InventoryTableViewController
            viewCon1.setType(type: .list)
            let navCon2 = self.newViewController(name: "Pantry")
            let viewCon2 = navCon2.childViewControllers[0] as! InventoryTableViewController
            viewCon2.setType(type: .pantry)
            
            self.bar.items = [TabmanBar.Item(title: "List"), TabmanBar.Item(title: "Pantry")]
            self.tabViewControllers = [navCon1, navCon2]
            return self.tabViewControllers
        }
    }

    
    func defaultPageIndex(forPageboyViewController pageboyViewController: PageboyViewController) -> PageboyViewController.PageIndex? {
        return .first
    }
    
    //MARK: Helper methods
    
    private func newViewController(name: String) -> UIViewController {  // It is actually a nav controller
                                                                        // but it throws a fit when I try to return an actual nav controller type.
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
        
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            appearance.layout.edgeInset = offset
        })
    }
    

}
