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
    
    var user: UserWithCash?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: User Initialization
    
    func attachUser(_ newUser: inout UserWithCash, sign: Int) {
        
        user = newUser
        
        // Set name label.
        personLabel.text = user!.name
        
        // Set handle label.
        handleLabel.text = "@\(user!.handle)"
        
        // Set balance label. 
        balanceLabel.text = PriceHelper.formatPriceDollarSign(price: user!.balance)
        
        var balColor: UIColor?
        switch sign {
        case 0:
            balColor = UIColor(red: 188/255, green: 71/255, blue: 71/255, alpha: 255/255)
        case 1:
            balColor = UIColor(red: 71/255, green: 188/255, blue: 85/255, alpha: 255/255)
        default:
            balColor = UIColor.gray
        }
        balanceLabel.textColor = balColor
    }
    

}
