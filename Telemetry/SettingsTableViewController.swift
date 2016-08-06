//
//  SettingsTableViewController.swift
//  Telemetry
//
//  Created by IMAC  on 05.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0){
            self.showAlert("Вы действительно хотите выйти из приложения?", msg: "")
        }
    }
    @IBAction func menuPressed(sender: AnyObject) {
         ApplicationState.sharedInstance().showLeftPanel()
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
