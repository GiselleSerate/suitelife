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

class BarcodeScannerViewController: BarcodeScannerController {
    
    var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.codeDelegate = self
        self.errorDelegate = self
        self.dismissalDelegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // We won't check to see the sender since we want to make sure the items are transferred regardless of transition
        // Perhaps check in the future if a cancel button is implemented
        
        print("Contents of items from barcode scanning: \(self.items.map {item in item.name})")
        print("Transferring to PantryTableViewController...")
        // Remove the blank row
        if PantryDataModel.sharedInstance.items.last?.name == "" {
            PantryDataModel.sharedInstance.items.removeLast()
        }
        // Append scanned items
        PantryDataModel.sharedInstance.items += self.items
        // Add back the blank row
        PantryDataModel.sharedInstance.items.append(Item(name: "", checked: false, price: 0.00))
        // Make a new blank scanned items list
        self.items = [Item]()
    }
    
}

extension BarcodeScannerViewController: BarcodeScannerCodeDelegate {
    
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        print("Barcode identified with code: \(code) and type: \(type).")
        
        let queryURL = "https://pod.opendatasoft.com/api/records/1.0/search/?dataset=pod_gtin&q=\(code)&rows=1"
        Alamofire.request(queryURL, method: .get)
            .responseJSON { response in
                
                var json = JSON(response.result.value!)
                let records = json["records"]
                let productName = "\(records[0]["fields"]["gtin_nm"])"
                print("Product name identified: \(productName), adding to list...")
                if productName != "null" {
                    let alert = UIAlertController(title: "Barcode found!", message: "Product name: \(productName)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    // add a new item to the list
                    self.items.append(Item(name: productName, checked: false, price: 0))
                    controller.present(alert, animated: true, completion: {controller.reset(animated: true)})
                } else {
                    let alert = UIAlertController(title: "Could not find barcode for code", message: code, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    controller.resetWithError()
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
