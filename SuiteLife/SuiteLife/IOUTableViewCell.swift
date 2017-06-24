//
//  IOUTableViewCell.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/23/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit

class IOUTableViewCell: UITableViewCell {

    @IBOutlet weak var personLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    weak var controller: IOUViewController?
    
    var user: User?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: User Initialization
    
    func attachUser(_ newUser: inout User) {
        
        user = newUser
        
        // Set name label.
        personLabel.text = user?.name
        
        // Set handle label.
        handleLabel.text = user?.handle
        
        // Set balance label. 
        balanceLabel.text = String(describing: user!.balance)
        
    }
    

}
