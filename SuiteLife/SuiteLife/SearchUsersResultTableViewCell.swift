//
//  SearchUsersResultTableViewCell.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/29/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//  We also need this prototype cell for SearchUsersViewController.

import UIKit

class SearchUsersResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}