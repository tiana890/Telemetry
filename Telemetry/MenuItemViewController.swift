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
        case profile = 0, maps = 1, company = 2, vehicles = 3, settings = 4, exit = 5
    }
    
    //MARK: UIViewController methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sub = self.table.rx.itemSelected.subscribeNext { [unowned self](indexPath) in
            switch ((indexPath as NSIndexPath).row){
            case MenuItemIndex.profile.rawValue:
                //NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: NotificationManager.MenuItemSelectedNotification, object: MenuItem.Profile.rawValue))
                break
            case MenuItemIndex.maps.rawValue:
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NotificationManager.MenuItemSelectedNotification), object: MenuItem.Maps.rawValue))
                break
            case MenuItemIndex.company.rawValue:
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NotificationManager.MenuItemSelectedNotification), object: MenuItem.Company.rawValue))
                break
            case MenuItemIndex.vehicles.rawValue:
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NotificationManager.MenuItemSelectedNotification), object: MenuItem.Vehicles.rawValue))
                break
            case MenuItemIndex.exit.rawValue:
                //self.showAlert("Вы действительно хотите выйти из приложения?", msg: "")
                break
            case MenuItemIndex.settings.rawValue:
                NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: NotificationManager.MenuItemSelectedNotification), object: MenuItem.Settings.rawValue))
                break
            default:
                break
            }
        }
        self.addSubscription(sub)
    }

    //MARK: -Alerts
    
    func showAlert(_ title: String, msg: String){
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Отмена",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        let exitAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
                appDelegate.exit()
            }
        }
        
        alert.addAction(exitAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
   }
