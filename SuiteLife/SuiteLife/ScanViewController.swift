//
//  ScanViewController.swift
//  SuiteLife
//
//  Created by cssummer17 on 7/10/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit

class ScanViewController: UIViewController {

    @IBOutlet weak var scanDestinationButton: UIButton!
    var currentScanDestination: InventoryType = .pantry
    var scanController: BarcodeScannerViewController?
    var barcodeScanner: Any? {
        didSet {
            print("Set barcodeScanner to \(barcodeScanner ?? "")")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // The first child view controller should be our scan controller
        scanController = childViewControllers[0] as! BarcodeScannerViewController
        
        // Add an action to the button
        scanDestinationButton.addTarget(self, action: #selector(toggleScanDestination), for: .touchUpInside)
        
    }

    func toggleScanDestination(sender: UIButton) {
        switch currentScanDestination {
        case .pantry:
            scanController!.scanDestination = .list
            currentScanDestination = .list
            scanDestinationButton.setTitle("List", for: .normal)
        case .list:
            scanController!.scanDestination = .pantry
            currentScanDestination = .pantry
            scanDestinationButton.setTitle("Pantry", for: .normal)
        default:
            fatalError("Invalid value of currentScanDestination \(currentScanDestination)")
        }
    }
    

}
