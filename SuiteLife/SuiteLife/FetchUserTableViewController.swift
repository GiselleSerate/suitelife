////
////  FetchUserTableViewController.swift
////  SuiteLife
////
////  Created by cssummer17 on 6/29/17.
////  Copyright © 2017 cssummer17. All rights reserved.
////
//
//import UIKit
//import Firebase
//
//class FetchUserTableViewController: UITableViewController, UITextFieldDelegate {
//    
//    
//    //MARK: Properties
//    
//    var resultsArray: [[String: String]] = []
//    let textCellIdentifier = "FetchUserInputTableViewCell"
//    let cellIdentifier = "FetchUserResultsTableViewCell"
//    var textField: UITextField?
//    let databaseRef = Database.database().reference()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Uncomment the following line to preserve selection between presentations
//        // self.clearsSelectionOnViewWillAppear = false
//
//        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    
//    // MARK: Text Field Delegate
//    
//    func textFieldDidChange(_ textField: UITextField) { // TODO: Somebody is resigning the first responder. please stop
//        updateResults(textField.text ?? "")
//    }
//    
//    
//    // MARK: Table View Data Source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        if resultsArray.count > 0 { // We have results to display. We need a second section. 
//            return 2
//        } else {
//            return 1
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        switch section {
//        case 0: // Singular field.
//            return 1
//        case 1: // There are results to display.
//            return resultsArray.count
//        default:
//            fatalError("Invalid section number \(section)")
//        }
//    }
//
//    // TODO: Band-aid. Use this function if nothing else works to resize the result cells.
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        switch indexPath.section {
//        case 0:
//            return 44
//        case 1:
//            return 60
//        default:
//            fatalError("Invalid section number \(indexPath.section)")
//        }
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch indexPath.section {
//        case 0:
//            // No configuration required for the input cell
//            let cell = tableView.dequeueReusableCell(withIdentifier: self.textCellIdentifier, for: indexPath) as! FetchUserInputTableViewCell
//            if self.textField == nil {
//                // get a reference to the input text field
//                // and configure it
//                self.textField = cell.textField
//                self.textField!.placeholder = "Search for user . . ."
//                self.textField!.delegate = self
//                self.textField!.returnKeyType = .done
//                self.textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
//            }
//            return cell
//        case 1:
//            // Configure property array cells
//            let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath) as! FetchUserResultsTableViewCell
//            cell.nameLabel.text = resultsArray[indexPath.row]["name"]!
//            cell.handleLabel.text = "@\(resultsArray[indexPath.row]["handle"]!)" // Will error if user has no handle, but user should have handle.
//            return cell
//        default:
//            fatalError("Invalid section \(indexPath.section)")
//        }
//
//    }
// 
//
//    /*
//    // Override to support conditional editing of the table view.
//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
//    */
//
//    /*
//    // Override to support editing the table view.
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            // Delete the row from the data source
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }    
//    }
//    */
//
//    /*
//    // Override to support rearranging the table view.
//    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
//
//    }
//    */
//
//    /*
//    // Override to support conditional rearranging of the table view.
//    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the item to be re-orderable.
//        return true
//    }
//    */
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//    
//    
//    // MARK: Private Methods
//    
//    private func updateResults(_ query: String) { // TODO: Overhaul way we store data to be able to search case insensitively.
//        if query.characters.count < 4 { // Don't search if the query is too short.
//            return
//        }
//        print("Updating results.")
//        self.databaseRef.child("users").queryOrdered(byChild: "name").queryStarting(atValue: query).queryEnding(atValue: query+"\u{f8ff}").queryLimited(toFirst:1).observeSingleEvent(of: .value, with: {(snapshot) in
//            for child in snapshot.children {
//                if let childRef = child as? DataSnapshot {
//                    var dict: [String: String] = [:]
//                    dict["userID"] = childRef.key
//                    dict["name"] = childRef.childSnapshot(forPath: "name").value as? String
//                    dict["handle"] = childRef.childSnapshot(forPath: "handle").value as? String
//                    self.resultsArray.append(dict)
//                    print(dict)
//                }
//            }
//            self.tableView.reloadData() // REFRESH PAGE.
//
//        }) {(error) in
//            print(error.localizedDescription)
//        }
//    }
//
//}
