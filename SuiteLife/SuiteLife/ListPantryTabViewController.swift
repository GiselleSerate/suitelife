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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Tabman setup
        
        self.dataSource = self
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            appearance.layout.edgeInset = 90 //TODO: figure out what values based on screen size will center this.
//            appearance.style.background = .clear
        })
        
        self.bar.location = .bottom
    
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
