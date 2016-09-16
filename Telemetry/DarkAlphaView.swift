//
//  DarkAlphaView.swift
//  GBU
//
//  Created by Agentum on 11.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit

class DarkAlphaView: UIView {
    
    weak var centerContainer: UIView?
    weak var leftContainer: UIView?
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if(self.alpha == 0.0){
            return super.hitTest(point, withEvent: event)
        } else {
            return centerContainer?.hitTest(point, withEvent: event)
        }
    }
    
}
