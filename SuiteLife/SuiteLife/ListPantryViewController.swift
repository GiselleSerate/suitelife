//
//  ListPantryViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/13/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit

class ListPantryViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return[               self.newViewController(name: "Pantry"), self.newViewController(name: "List")
]
    }()
    
    private func newViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(name)ViewController")
    }
    
    //TODO: once this is working we're going to replace them with the actual table view controllers.

}

//MARK: extension

extension ListPantryViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard (nextIndex < orderedViewControllers.count) else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard (previousIndex >= 0) && (previousIndex < orderedViewControllers.count) else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    

}
