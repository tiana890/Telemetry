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
        case Profile, Map
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedViewController = self.viewControllers![TabBarItem.Map.rawValue]
        
        subscription = NSNotificationCenter.defaultCenter().rx_notification(NotificationManager.MenuItemSelectedNotification).subscribeNext { (notification) in
            if let value = notification.object as? String{
                if let menuItem = MenuItem(rawValue: value){
                    switch(menuItem){
                    case MenuItem.Profile:
                        break
                    case MenuItem.Maps:
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
    
    //MARK: Menu control functions
    func menuProtocolShowMap(){
        ApplicationState.sharedInstance().hideLeftPanel()
        self.selectedIndex = TabBarItem.Map.rawValue
    }

    func menuProtocolShowProfile() {
        ApplicationState.sharedInstance().hideLeftPanel()
        self.selectedIndex = TabBarItem.Profile.rawValue
    }

    deinit{
        print("TAB BAR DEINIT")
    }
}

