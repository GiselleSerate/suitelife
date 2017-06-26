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

    // Woo global variables.
    
    override func viewDidLoad() {
        print("CALLED VIEWDIDLOAD")
        super.viewDidLoad()
        
        // Tabman setup
        
        // Get font sizing.
        let font = UIFont.systemFont(ofSize: 16)
        let fontAttributes = [NSFontAttributeName: font] // it says name, but a UIFont works
        let myText = "PantryList"
        let tabmanWidth = (myText as NSString).size(attributes: fontAttributes)
        
        // Set offset using font sizing.
        let offset = (view.bounds.maxX-tabmanWidth.width-40)/2
        print("The width of the view is \(view.bounds.maxX)")
        
        self.dataSource = self
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            appearance.layout.edgeInset = offset //TODO: figure out what values based on screen size will center this.
        }) // TODO: reset this when the screen rotates???? I don't even know if I need to do this.
        
        self.bar.location = .bottom
        
    }
    
    
    // Runs when the device rotates.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print("DEVICE ROTATED")
//        if (ListPantryTabViewController.view.window != nil) {
            self.viewDidLoad()
//            super.viewWillTransition(to: size, with: coordinator)
//        }
    }

    //MARK: Tabman
    func viewControllers(forPageboyViewController pageboyViewController: PageboyViewController) -> [UIViewController]? {
        // Create the view controllers for the Pantry and List tables and order them
        let viewCon1 = self.newViewController(name: "List")
        let viewCon2 = self.newViewController(name: "Pantry")
        let viewControllers = [viewCon1, viewCon2]
        self.bar.items = [TabmanBar.Item(title: "List"), TabmanBar.Item(title: "Pantry")]
        return viewControllers
    }

    
    func defaultPageIndex(forPageboyViewController pageboyViewController: PageboyViewController) -> PageboyViewController.PageIndex? {
        return nil
    }
    
    //MARK: Helper methods
    
    private func newViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(name)NavTableViewController")
    }
    

}
