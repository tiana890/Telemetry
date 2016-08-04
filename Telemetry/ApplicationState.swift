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
    
    //MARK: Controllers
    weak var containerViewController: ContainerViewController?
    
    //MARK: Support classes
    var filter: Filter?
    
    weak var leftPanelDelegate: APPLeftPanelIsShown?
    
    static func sharedInstance() -> ApplicationState{
        struct Static {
            static var onceToken : dispatch_once_t = 0
            static var instance : ApplicationState? = nil
            
        }
        
        dispatch_once(&Static.onceToken) {
            Static.instance = ApplicationState()
            Static.instance?.filter = Filter()
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
    
    func saveToken(token: String){
        PreferencesManager.saveToken(token)
    }
    
    func getToken() -> String?{
        return PreferencesManager.getToken()
    }
    
    func deleteToken(){
        PreferencesManager.deleteToken()
    }
    
}

