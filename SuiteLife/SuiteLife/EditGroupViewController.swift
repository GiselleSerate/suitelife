//
//  EditGroupViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/30/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Firebase

class EditGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var memberArray: [User] = []
    var groupID: String?
    let databaseRef = Database.database().reference()
    let userID = Auth.auth().currentUser!.uid
    
    @IBOutlet weak var nameField: UITextField!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
                
        createUsersByID(userIDs: [self.userID])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addMember(member: User) {
        if !memberArray.contains(member) {
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
        var alert: UIAlertController
        if self.userID != memberArray[indexPath.row].userID {
            alert = UIAlertController(title: "Remove \(memberArray[indexPath.row].name)?", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(.init(title: "OK", style: .default, handler: {(element) in
                self.memberArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }))
        }
        else {
            alert = UIAlertController(title: "You cannot remove yourself from a group.", message: nil, preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: Firebase
    
    func loadGroup(groupID: String) {
        print("Calling load group")
        self.groupID = groupID
        self.navigationItem.title = "Edit Group"
        self.databaseRef.child("groups/\(groupID)").observeSingleEvent(of: .value, with: { snapshot in
            print("LOADGROUP CALLBACK")
            self.nameField.text = snapshot.childSnapshot(forPath: "name").value as? String // found nil while unwrapping Optional on 2nd run. Not even that I changed anything.
            let children = snapshot.childSnapshot(forPath: "members").children
            var memberIDArray: [String] = []
            for child in children {
                memberIDArray.append((child as! DataSnapshot).key)
            }
            self.createUsersByID(userIDs: memberIDArray)
        }) { (error) in
        print(error.localizedDescription)}
    }
    
    func saveGroup() {
        var group: DatabaseReference
        let user = databaseRef.child("users/\(self.userID)")
        if groupID == nil {
            group = databaseRef.child("groups").childByAutoId()
        }
        else {
            group = databaseRef.child("groups/\(groupID!)")
        }
        group.child("name").setValue(nameField.text)
        // clear the whole members tree
        // TODO: replace line below with call to removeMembers() -- keep track of which members to remove
        group.child("members").setValue(nil)
        // first save the user into the group so that it can be edited
        group.child("members/\(self.userID)").setValue(true)
        // then set the remaining user values
        for member in memberArray {
            if member.userID != self.userID {
                let child = group.child("members/\(member.userID)")
                child.setValue(true)
                user.child("groups/\(group.key)").setValue(true)
            }
        }
//        group.child("members").setValue(memberArray.map{$0.userID})
    }
    
    private func createUsersByID(userIDs: [String]) {
        for userID in userIDs {

            if !memberArray.contains{$0.userID == userID}{
                print("User ID is: \(userID)")
                print(userID==self.userID)
                databaseRef.child("users/\(userID)").observeSingleEvent(of: .value, with: { snapshot in
                    let name = snapshot.childSnapshot(forPath: "name").value as! String
                    let handle = snapshot.childSnapshot(forPath: "handle").value as! String
                    self.addMember(member: User(name: name, handle: handle, userID: userID))
                    self.tableView.reloadData()
                })
            }
        }
    }

    
    // MARK: Cancel Button
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        print("Cancel button was pressed.")
        self.dismiss(animated: true, completion: nil)
//        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        print("Save button was pressed.")
        saveGroup()
        self.dismiss(animated: true, completion: nil)
//        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation

//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
 
}