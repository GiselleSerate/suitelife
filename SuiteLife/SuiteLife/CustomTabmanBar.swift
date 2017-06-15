//
//  CustomTabmanBar.swift
//  SuiteLife
//
//  Created by cssummer17 on 6/15/17.
//  Copyright © 2017 cssummer17. All rights reserved.
//

import UIKit
import Tabman
import Pageboy
import PureLayout

class CustomTabmanBar: TabmanBar {

    // MARK: Lifecycle
    
    override func defaultIndicatorStyle() -> TabmanIndicator.Style {
        // declare indicator style here
        return .clear
    }
    
    override func usePreferredIndicatorStyle() -> Bool {
        // Whether to use preferredIndicatorStyle
        return true
    }
    
    // MARK: TabmanBar Lifecycle
    
    public override func constructTabBar(items: [TabmanBarItem]) {
        
        // create your bar here
        let label = UILabel()
        label.text = "This is a custom TabmanBar"
        label.textAlignment = .center
        label.textColor = .white
        self.contentView.addSubview(label)
        label.autoPinEdgesToSuperviewEdges(with: UIEdgeInsetsMake(40.0, 0.0, 12.0, 0.0))
    }
    
    public override func addIndicatorToBar(indicator: TabmanIndicator) {
        // add indicator to bar here
    }
    
    override func update(forPosition position: CGFloat,
                         direction: PageboyViewController.NavigationDirection,
                         indexRange: Range<Int>,
                         bounds: CGRect) {
        super.update(forPosition: position,
                     direction: direction,
                     indexRange: indexRange,
                     bounds: bounds)
        // update your bar for a positional update here
    }
    
    override func update(forAppearance appearance: Appearance,
                         defaultAppearance: Appearance) {
        super.update(forAppearance: appearance,
                     defaultAppearance: defaultAppearance)
        
        // update the bar appearance here
    }


}

