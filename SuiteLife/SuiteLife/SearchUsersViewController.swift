//
//  SearchUsersViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/30/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Firebase

class SearchUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    

    // MARK: Properties
    
    static let minQueryLength = 3

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let databaseRef = Database.database().reference()

    var searchResults: [User] = []

    // MARK: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        searchBar.delegate = self
        searchBar.autocapitalizationType = .none
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonPressed))
    }

    // MARK: UITableViewDelegate and UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "UserNameAndHandleTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! UserNameAndHandleTableViewCell
        cell.nameLabel.text = searchResults[indexPath.row].name
        cell.handleLabel.text = "@\(searchResults[indexPath.row].handle)"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // assert nav controller exists
        let viewControllers = self.navigationController!.viewControllers
        let prevViewController = viewControllers[viewControllers.count - 2] as! EditGroupViewController
        prevViewController.addMember(member: searchResults[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Search Bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchResults = [] // Clear search results.
        if searchText.characters.count < SearchUsersViewController.minQueryLength { // Don't search if the query is too short.
            tableView.reloadData()
            return
        }
        print("Updating results.")
        
        // Search user database by name.
        self.databaseRef.child("users").queryOrdered(byChild: "searchFields/name").queryStarting(atValue: searchText).queryEnding(atValue: searchText+"\u{f8ff}").queryLimited(toFirst:10).observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                if let childRef = child as? DataSnapshot {
                    let userID = childRef.key
                    let name = childRef.childSnapshot(forPath: "name").value as! String
                    let handle = childRef.childSnapshot(forPath: "handle").value as! String
                    self.searchResults.append(User(name: name, handle: handle, userID: userID))
                }
            }
            self.tableView.reloadData() // REFRESH PAGE.
            
        }) {(error) in
            print(error.localizedDescription)
        }
        
        // Search user database by handle, check if in searchResults yet.
        self.databaseRef.child("users").queryOrdered(byChild: "searchFields/handle").queryStarting(atValue: searchText).queryEnding(atValue: searchText+"\u{f8ff}").queryLimited(toFirst:10).observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                if let childRef = child as? DataSnapshot {
                    let handle = childRef.childSnapshot(forPath: "handle").value as! String
                    if !(self.searchResults.contains{$0.handle == handle}) {
                        let userID = childRef.key
                        let name = childRef.childSnapshot(forPath: "name").value as! String
                        self.searchResults.append(User(name: name, handle: handle, userID: userID))
                    }
                }
            }
            self.tableView.reloadData() // REFRESH PAGE.
            
        }) {(error) in
            print(error.localizedDescription)
        }
    }

    
    // MARK: Navigation Bar
    
    func cancelButtonPressed() {
        print("Cancel button was pressed.")
        navigationController?.popViewController(animated: true)
    }

}
