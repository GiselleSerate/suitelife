//
//  LoadGroupTestViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/30/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit

class LoadGroupTestViewController: UIViewController {

    @IBOutlet weak var groupID: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print(sender)
//        if let sendButton = sender as? UIBarButtonItem {
//            print("Sent from Bar Item")
//            return
//        }
        if let nextViewController = segue.destination as? UINavigationController {
            if let groupViewController = nextViewController.viewControllers.last as?  GroupsViewController {
                print("Preparing to call load group")
                groupViewController.loadGroup(groupID: groupID.text!)
            }
        }
    }
 

}
