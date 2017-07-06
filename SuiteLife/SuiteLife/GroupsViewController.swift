//
//  GroupsViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 7/5/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Firebase

class GroupsViewController: UITableViewController {
    
    var groups: [Group] = []
    
    let databaseRef = Database.database().reference()
    let currentUserID = Auth.auth().currentUser!.uid

    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        // No edit button for now -- swipe left to delete
        // self.navigationItem.leftBarButtonItem = self.editButtonItem
        navigationItem.title = "Groups"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Attempting to load groups...")
        loadGroups()
    }
    
    //MARK: UITableViewController
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Only one section, so return 1
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Only one section, so don't bother looking to the section number
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "GroupsTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GroupsTableViewCell else {
            fatalError("Cell with identifier \(cellIdentifier) not of type GroupsTableViewCell")
        }
        cell.textLabel?.text = groups[indexPath.row].name
        cell.groupID = groups[indexPath.row].groupID
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let group = self.groups[indexPath.row]
            let alert = UIAlertController(title: "Leave \(group.name)?", message: "If you wish to rejoin, a current member must add you.", preferredStyle: .alert)
            alert.addAction(.init(title: "No", style: .default, handler: nil))
            alert.addAction(.init(title: "Yes", style: .default, handler: {(element) in
                // Remove the current user from the group
                self.databaseRef.child("groups/\(group.groupID)/members/\(self.currentUserID)").setValue(nil)
                // Remove the group from the user's list
                self.databaseRef.child("users/\(self.currentUserID)/groups/\(group.groupID)").setValue(nil)
                // Delete the row from the data source
                self.groups.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }))
            present(alert, animated: true,completion: nil)
        }
        // Do nothing if the editing style is somehow .insert
    }
    
    // Implemented to allow editing of the cells (i.e. removal)
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Implemented to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {}
    
    // Implemented to support conditional rearrangement
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    //MARK: Private Methods
    
    private func loadGroups() {
        // Clear groups
        groups = []
        self.databaseRef.child("users/\(currentUserID)/groups").observeSingleEvent(of: .value, with: { (snapshot) in
            let children = snapshot.children
            var groupIDs: [String] = []
            for child in children {
                groupIDs.append((child as! DataSnapshot).key)
            }
            self.createGroups(from: groupIDs)
        }) { (error) in
            print(error.localizedDescription)}
    }

    
    private func createGroups(from groupIDs: [String]) {
        for groupID in groupIDs {
            databaseRef.child("groups/\(groupID)/name").observeSingleEvent(of: .value, with: {(snapshot) in
                let groupName = snapshot.value as! String
                self.groups.append(Group(groupID: groupID, name: groupName))
                if groupID == groupIDs.last {
                    print("Loaded groups.")
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    //MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch(segue.identifier ?? "") {
        case "CreateGroup":
            guard let navController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let groupViewController = navController.viewControllers.last as? EditGroupViewController else {
                fatalError("Unexpected view controller: \(navController.viewControllers.last)")
            }
            groupViewController.navigationItem.title = "New Group"
            
        case "EditGroup":
            guard let navController = segue.destination as? UINavigationController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let groupViewController = navController.viewControllers.last as? EditGroupViewController else {
                fatalError("Unexpected view controller: \(navController.viewControllers.last)")
            }
            guard let selectedGroup = sender as? GroupsTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "")")
            }
            print("Preparing to call load group")
            groupViewController.loadGroup(groupID: selectedGroup.groupID!)
        
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier ?? "")")
        }

        }
    
    // MARK: IBActions

    @IBAction func exitView(_ sender: UIBarButtonItem) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
    }
}
