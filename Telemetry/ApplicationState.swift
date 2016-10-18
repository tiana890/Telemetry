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
    
//    private static var __once: () = {
//            self =  ApplicationState()
//            self.filter = Filter()
//        }()
    
    //MARK: Controllers
    weak var containerViewController: ContainerViewController?
    
    //MARK: Support classes
    var filter: Filter?
    
    weak var leftPanelDelegate: APPLeftPanelIsShown?
    
    static let sharedInstance : ApplicationState = {
        let instance = ApplicationState()
        instance.filter = Filter()
        return instance
    }()
    
//    static func sharedInstance() -> ApplicationState{
//        struct Static {
//            static var onceToken : Int = 0
//            static var instance : ApplicationState? = nil
//        }
//        
//        _ = ApplicationState.__once
//        return __once!
//    }
    
    func showLeftPanel(){
        containerViewController?.animatedLeftMoveViewToRightEdge()
        self.leftPanelDelegate?.appLeftPanelOpened()
    }
    
    func hideLeftPanel(){
        containerViewController?.animatedLeftMoveViewToLeftEdge()
    }
    
    func saveToken(_ token: String){
        PreferencesManager.saveToken(token)
    }
    
    func getToken() -> String?{
        return PreferencesManager.getToken()
    }
    
    func deleteToken(){
        PreferencesManager.deleteToken()
    }
    
    func isFilterSet() -> Bool{
        return filter?.filterIsSet() ?? false
    }
}

