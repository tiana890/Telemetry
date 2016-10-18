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
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if(self.alpha == 0.0){
            return super.hitTest(point, with: event)
        } else {
            return centerContainer?.hitTest(point, with: event)
        }
    }
    
}
