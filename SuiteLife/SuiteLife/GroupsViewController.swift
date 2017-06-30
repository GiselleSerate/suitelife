//
//  GroupsViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/30/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Firebase

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var memberArray: [User] = []
    var groupID: String?
    let databaseRef = Database.database().reference()
    
    @IBOutlet weak var nameField: UITextField!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addMember(member: User) {
        if !memberArray.contains{$0==member} {
            print("Added member with name \(member.name).")
            self.memberArray.insert(member, at: 0)
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchUsersResultTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchUsersResultTableViewCell
        cell.nameLabel.text = memberArray[indexPath.row].name
        cell.handleLabel.text = "@\(memberArray[indexPath.row].handle)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Remove \(memberArray[indexPath.row].name)?", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(.init(title: "OK", style: .default, handler: {(element) in
            self.memberArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Firebase
    
    func loadGroup(groupID: String) {
        databaseRef.child("groups/\(groupID)").observe(.value, with: { snapshot in
            self.nameField.text = snapshot.childSnapshot(forPath: "name").value as? String
            let memberIDArray = snapshot.childSnapshot(forPath: "members").value as! [String]
            self.createUsersByID(userIDs: memberIDArray)
        })
    }
    
    func saveGroup() {
        var group: DatabaseReference
        if groupID == nil {
            group = databaseRef.child("groups").childByAutoId()
        }
        else {
            group = databaseRef.child("groups/\(groupID!)")
        }
        group.child("name").setValue(nameField.text)
        group.child("members").setValue(memberArray.map{$0.userID})
    }
    
    private func createUsersByID(userIDs: [String]) {
        for userID in userIDs {
            databaseRef.child("users/\(userID)").observe(.value, with: { snapshot in
                let name = snapshot.childSnapshot(forPath: "name").value as! String
                let handle = snapshot.childSnapshot(forPath: "handle").value as! String
                self.memberArray.append(User(name: name, handle: handle, userID: userID))
            })
        }
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
