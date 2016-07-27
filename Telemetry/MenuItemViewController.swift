//
//  MenuTableViewController.swift
//  GBU
//
//  Created by IMAC  on 03.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import CoreGraphics
import RxSwift
import RxCocoa


class MenuTableViewController: BaseTableViewController{
    
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet var email: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var table: UITableView!
    
    var ifLoading = false
    
    
    @IBOutlet weak var numberOfMyTasks: UILabel!
    enum MenuItemIndex: Int{
        case Profile = 0, Maps = 1, Organization = 2, Vehicles = 3, Settings = 4, Exit = 5
    }
    
    //MARK: UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sub = self.table.rx_itemSelected.subscribeNext { (indexPath) in
            switch (indexPath.row){
            case MenuItemIndex.Profile.rawValue:
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: NotificationManager.MenuItemSelectedNotification, object: MenuItem.Profile.rawValue))
                break
            case MenuItemIndex.Maps.rawValue:
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: NotificationManager.MenuItemSelectedNotification, object: MenuItem.Maps.rawValue))
                break
            case MenuItemIndex.Organization.rawValue:
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: NotificationManager.MenuItemSelectedNotification, object: MenuItem.Organization.rawValue))
            case MenuItemIndex.Vehicles.rawValue:
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: NotificationManager.MenuItemSelectedNotification, object: MenuItem.Vehicles.rawValue))
            case MenuItemIndex.Exit.rawValue:
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: NotificationManager.MenuItemSelectedNotification, object: MenuItem.Exit.rawValue))
            case MenuItemIndex.Settings.rawValue:
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: NotificationManager.MenuItemSelectedNotification, object: MenuItem.Settings.rawValue))
            default:
                break
            }
        }
        self.addSubscription(sub)
    }

    
   }
