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
        case profile, map, company, vehicles, settings, exit
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedViewController = self.viewControllers![TabBarItem.map.rawValue]
        
        subscription = NotificationCenter.default.rx.notification(Notification.Name(rawValue: NotificationManager.MenuItemSelectedNotification)).subscribeNext { (notification) in
            if let value = notification.object as? String{
                if let menuItem = MenuItem(rawValue: value){
                    switch(menuItem){
                    case MenuItem.Profile:
                        self.showProfile()
                        break
                    case MenuItem.Maps:
                        self.showMap()
                        break
                    case MenuItem.Company:
                        self.showCompanies()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBar.isHidden = true
        
        ApplicationState.sharedInstance.containerViewController?.centerTabBarController = self
    }
    
    //MARK: Menu functions
    func showMap(){
        ApplicationState.sharedInstance.hideLeftPanel()
        self.selectedIndex = TabBarItem.map.rawValue
    }

    func showProfile() {
        ApplicationState.sharedInstance.hideLeftPanel()
        self.selectedIndex = TabBarItem.profile.rawValue
    }

    func showVehicles(){
        ApplicationState.sharedInstance.hideLeftPanel()
        self.selectedIndex = TabBarItem.vehicles.rawValue
    }
    
    func showSettings(){
        ApplicationState.sharedInstance.hideLeftPanel()
        self.selectedIndex = TabBarItem.settings.rawValue
    }
    
    func showCompanies(){
        ApplicationState.sharedInstance.hideLeftPanel()
        self.selectedIndex = TabBarItem.company.rawValue
    }
    
    deinit{
        print("TAB BAR DEINIT")
    }
}

