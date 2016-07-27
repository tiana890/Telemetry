//
//  TabBarController.swift
//  Telemetry
//
//  Created by IMAC  on 25.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//


import UIKit
import RxSwift

class TabBarViewController: UITabBarController{
    var disposeBag = DisposeBag()
    var subscription: Disposable?
    
    enum TabBarItem: Int{
        case Profile, Map, Vehicles, Organization, Settings, Exit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedViewController = self.viewControllers![TabBarItem.Map.rawValue]
        
        subscription = NSNotificationCenter.defaultCenter().rx_notification(NotificationManager.MenuItemSelectedNotification).subscribeNext { (notification) in
            if let value = notification.object as? String{
                if let menuItem = MenuItem(rawValue: value){
                    switch(menuItem){
                    case MenuItem.Profile:
                        self.showProfile()
                        break
                    case MenuItem.Maps:
                        self.showMap()
                        break
                    case MenuItem.Organization:
                        self.showOrganizations()
                        break
                    case MenuItem.Settings:
                        self.showSettings()
                        break
                    case MenuItem.Vehicles:
                        self.showVehicles()
                        break
                    default:
                        break
                    }
                }
            }
        }
        subscription?.addDisposableTo(self.disposeBag)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBar.hidden = true
        
        ApplicationState.sharedInstance().containerViewController?.centerTabBarController = self
    }
    
    //MARK: Menu functions
    func showMap(){
        ApplicationState.sharedInstance().hideLeftPanel()
        self.selectedIndex = TabBarItem.Map.rawValue
    }

    func showProfile() {
        ApplicationState.sharedInstance().hideLeftPanel()
        self.selectedIndex = TabBarItem.Profile.rawValue
    }

    func showVehicles(){
        ApplicationState.sharedInstance().hideLeftPanel()
        self.selectedIndex = TabBarItem.Vehicles.rawValue
    }
    
    func showSettings(){
        ApplicationState.sharedInstance().hideLeftPanel()
        self.selectedIndex = TabBarItem.Organization.rawValue
    }
    
    func showOrganizations(){
        ApplicationState.sharedInstance().hideLeftPanel()
        self.selectedIndex = TabBarItem.Settings.rawValue
    }
    
    deinit{
        print("TAB BAR DEINIT")
    }
}

