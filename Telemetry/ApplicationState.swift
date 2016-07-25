//
//  APP.swift
//  DBAccessInUse
//
//  Created by Agentum on 24.08.15.
//  Copyright (c) 2015 IMAC . All rights reserved.
//

import UIKit

protocol APPLeftPanelIsShown: class{
    func appLeftPanelOpened()
}

class ApplicationState{
    var token: String?
    
    //MARK: Controllers
    weak var containerViewController: ContainerViewController?
    
    //MARK: Support classes

    weak var leftPanelDelegate: APPLeftPanelIsShown?
    
    static func sharedInstance() -> ApplicationState{
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : ApplicationState? = nil
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = ApplicationState()
            
        }
        return Static.instance!
    }
    
    func showLeftPanel(){
        containerViewController?.animatedLeftMoveViewToRightEdge()
        self.leftPanelDelegate?.appLeftPanelOpened()
    }
    
    func hideLeftPanel(){
        containerViewController?.animatedLeftMoveViewToLeftEdge()
    }
    
    
}

