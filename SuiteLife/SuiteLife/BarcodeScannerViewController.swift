//
//  BarcodeScannerViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/16/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import BarcodeScanner
import Alamofire
import SwiftyJSON
import os.log
import Firebase

class BarcodeScannerViewController: BarcodeScannerController {
    
    let databaseRef = Database.database().reference()
    let currentUserID = Auth.auth().currentUser!.uid
    
    var items = [Item]()
    
    var scanDestination: InventoryType = .pantry
    var scanGroup = "personal"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // BarcodeScannerController required delegates
        codeDelegate = self
        errorDelegate = self
        dismissalDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Clear the contents of items upon reload
        items = []
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Debug messages
        print("Contents of items from barcode scanning: \(items.map {item in item.name})")
        saveItems()
    }
    
    private func saveItems() {
        // TODO: Currently only saves to personal list, add flexibility for save destination
        var destination: String
        switch scanDestination {
        case .pantry:
            destination = "pantry"
        case .list:
            destination = "list"
        default:
            fatalError("Unexpected value for scanDestination: \(scanDestination)")
        }
        databaseRef.child("users/\(currentUserID)/\(destination)").runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            var newList: [NSDictionary]
            let currentItems = self.items.map{$0.toDict()}
            if let oldList = currentData.value as? [NSDictionary] {
                newList = oldList + currentItems
                print("Old \(destination): \(oldList)")
            }
            else {
                newList = currentItems
                print("Old \(destination) doesn't exist, creating new one...")
            }
            
            currentData.value = newList
            return TransactionResult.success(withValue: currentData)
            
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
            if committed {
                print("Saved scanned items to \(destination).")
            }
            print("Value of data saved: \(snapshot?.value ?? "").")
        }
    }

    
}

extension BarcodeScannerViewController: BarcodeScannerCodeDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        // When a barcode is found...
        
        print("Barcode identified with code: \(code) and type: \(type).")
        
        // Make a query to opendatasoft's product database
        let queryURL = "https://pod.opendatasoft.com/api/records/1.0/search/?dataset=pod_gtin&q=\(code)&rows=1"
        Alamofire.request(queryURL, method: .get)
            .responseJSON { response in
                // When the response is returned...
                
                // Get the JSON and then product name
                var json = JSON(response.result.value!)
                let records = json["records"]
                let productName = "\(records[0]["fields"]["gtin_nm"])"
                
                if productName != "null" {
                    // If the product exists in the database...
                    
                    // Create an alert to let the user know it succeeded
                    let alert = UIAlertController(title: "Barcode found!", message: "Product name: \(productName)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    // Add a new item for the product to the list
                    print("Adding \(productName) to the scanned items list...")
                    self.items.append(Item(name: productName, checked: false, price: 0))
                    
                    // Show the alert and then reset the barcode scanner
                    controller.present(alert, animated: true, completion: {controller.reset(animated: true)})
                } else {
                    // If the product does not exist in the database...
                    
                    // Create an alert to let the user know it failed
                    let alert = UIAlertController(title: "Could not find barcode for code", message: code, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    // Reset with an error
                    controller.resetWithError()
                    
                    // And present the alert
                    controller.present(alert, animated: true, completion: nil)
                }
        }
        
    }
}

extension BarcodeScannerViewController: BarcodeScannerErrorDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        print(error)
    }
}

extension BarcodeScannerViewController: BarcodeScannerDismissalDelegate {
    
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
