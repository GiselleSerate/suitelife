// NOPE I THINK WE'RE GETTING RID OF THISS????
//  TallerNavBar.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/15/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit

class TallerNavBar: UINavigationBar {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let newSize:CGSize = CGSize(width: self.frame.size.width, height: 87)
        return newSize
    }

}
