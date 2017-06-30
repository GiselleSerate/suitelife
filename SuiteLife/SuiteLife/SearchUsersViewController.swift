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

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let databaseRef = Database.database().reference()

    var searchResults: [[String:String]] = []
    // [USERID: value, HANDLE: value, NAME: value]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        searchBar.autocapitalizationType = .none
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonPressed))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SearchUsersResultTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchUsersResultTableViewCell
        cell.nameLabel.text = searchResults[indexPath.row]["name"]
        cell.handleLabel.text = "@\(searchResults[indexPath.row]["handle"]!)"
        return cell
    }
    
    // TODO: Band-aid. Use this function if nothing else works to resize the result cells.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // assert nav controller exists
        let viewControllers = self.navigationController!.viewControllers
        let prevViewController = viewControllers[viewControllers.count - 2]
        prevViewController.navigationItem.title = searchResults[indexPath.row]["name"]
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Search Bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { // TODO: Implement for handle.
        self.searchResults = [] // Clear search results.
        if searchText.characters.count < 4 { // Don't search if the query is too short.
            self.tableView.reloadData()
            return
        }
        print("Updating results.")
        self.databaseRef.child("users").queryOrdered(byChild: "name").queryStarting(atValue: searchText).queryEnding(atValue: searchText+"\u{f8ff}").queryLimited(toFirst:10).observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                if let childRef = child as? DataSnapshot {
                    var dict: [String: String] = [:]
                    dict["userID"] = childRef.key
                    dict["name"] = childRef.childSnapshot(forPath: "name").value as? String
                    dict["handle"] = childRef.childSnapshot(forPath: "handle").value as? String
                    self.searchResults.append(dict)
                    print(dict)
                }
            }
            self.tableView.reloadData() // REFRESH PAGE.
            
        }) {(error) in
            print(error.localizedDescription)
        }
        self.databaseRef.child("users").queryOrdered(byChild: "handle").queryStarting(atValue: searchText).queryEnding(atValue: searchText+"\u{f8ff}").queryLimited(toFirst:10).observeSingleEvent(of: .value, with: {(snapshot) in
            for child in snapshot.children {
                if let childRef = child as? DataSnapshot {
                    let handle = childRef.childSnapshot(forPath: "handle").value as? String
                    if !(self.searchResults.contains{$0["handle"] == handle}) {
                        var dict: [String: String] = [:]
                        dict["userID"] = childRef.key
                        dict["name"] = childRef.childSnapshot(forPath: "name").value as? String
                        dict["handle"] = childRef.childSnapshot(forPath: "handle").value as? String
                        self.searchResults.append(dict)
                        print(dict)
                    }
                }
            }
            self.tableView.reloadData() // REFRESH PAGE.
            
        }) {(error) in
            print(error.localizedDescription)
        }
    }

    
    func cancelButtonPressed() {
        print("Cancel button was pressed.")
        navigationController?.popViewController(animated: true)
    }
 

}
