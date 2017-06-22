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

        // Do any additional setup after loading the view.
        self.dataSource = self
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            appearance.layout.edgeInset = 90 //TODO: figure out what values based on screen size will center this.
//            appearance.style.background = .clear
        })
        
        self.bar.location = .bottom
    
    }

    func viewControllers(forPageboyViewController pageboyViewController: PageboyViewController) -> [UIViewController]? {
        let viewCon1 = self.newViewController(name: "List")
        let viewCon2 = self.newViewController(name: "Pantry")
        let viewControllers = [viewCon1, viewCon2]
        self.bar.items = [TabmanBar.Item(title: "List"), TabmanBar.Item(title: "Pantry")]
        return viewControllers
    }
    
    private func newViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(name)NavTableViewController")
    }
    
    func defaultPageIndex(forPageboyViewController pageboyViewController: PageboyViewController) -> PageboyViewController.PageIndex? {
        return nil
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
