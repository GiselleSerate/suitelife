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

class BarcodeScannerViewController: BarcodeScannerController {
    
    var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // BarcodeScannerController required delegates
        self.codeDelegate = self
        self.errorDelegate = self
        self.dismissalDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Debug messages
        print("Contents of items from barcode scanning: \(self.items.map {item in item.name})")
        print("Transferring to PantryTableViewController...")
        // Remove the blank row
        if PantryDataModel.sharedInstance.items.last?.name == "" {
            PantryDataModel.sharedInstance.items.removeLast()
        }
        // Append scanned items
        PantryDataModel.sharedInstance.items += self.items
        // Add back the blank row
        PantryDataModel.sharedInstance.items.append(Item(name: "", checked: false, price: 0))
        // Make a new blank scanned items list
        self.items = [Item]()
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
