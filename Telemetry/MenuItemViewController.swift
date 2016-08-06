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
        case Profile = 0, Maps = 1, Company = 2, Vehicles = 3, Settings = 4, Exit = 5
    }
    
    //MARK: UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sub = self.table.rx_itemSelected.subscribeNext { [unowned self](indexPath) in
            switch (indexPath.row){
            case MenuItemIndex.Profile.rawValue:
                //NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: NotificationManager.MenuItemSelectedNotification, object: MenuItem.Profile.rawValue))
                break
            case MenuItemIndex.Maps.rawValue:
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: NotificationManager.MenuItemSelectedNotification, object: MenuItem.Maps.rawValue))
                break
            case MenuItemIndex.Company.rawValue:
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: NotificationManager.MenuItemSelectedNotification, object: MenuItem.Company.rawValue))
                break
            case MenuItemIndex.Vehicles.rawValue:
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: NotificationManager.MenuItemSelectedNotification, object: MenuItem.Vehicles.rawValue))
                break
            case MenuItemIndex.Exit.rawValue:
                //self.showAlert("Вы действительно хотите выйти из приложения?", msg: "")
                break
            case MenuItemIndex.Settings.rawValue:
                NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: NotificationManager.MenuItemSelectedNotification, object: MenuItem.Settings.rawValue))
                break
            default:
                break
            }
        }
        self.addSubscription(sub)
    }

    //MARK: -Alerts
    
    func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "Отмена",
                                         style: .Cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        let exitAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate{
                appDelegate.exit()
            }
        }
        
        alert.addAction(exitAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
   }
