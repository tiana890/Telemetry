//
//  SettingsTableViewController.swift
//  Telemetry
//
//  Created by IMAC  on 05.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsTableViewController: UITableViewController {
    
    
    //MARK: Rx Entities
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.row == 0){
            self.showAlert("Вы действительно хотите обновить справочники ТС?", msg: "Это займет некоторое время")
        } else if(indexPath.row == 2){
            self.showExitAlert("Вы действительно хотите выйти из приложения?", msg: "")
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
        
        let updateAction = UIAlertAction(title: "OK", style: .Default) { (action) in

            let progressHUD = ProgressHUD(text: "Загрузка справочника ТС. Подождите некоторое время.")
            progressHUD.tag = 1234
            progressHUD.frame.size = CGSize(width: 280.0, height: 50.0)
            progressHUD.center = self.view.center
            self.view.addSubview(progressHUD)
            self.view.userInteractionEnabled = false
            
            AutosClient(_token: ApplicationState.sharedInstance().getToken() ?? "").autosDictObservable()
                .observeOn(MainScheduler.instance)
                .subscribeNext { (autosDictResponse) in
                    progressHUD.removeFromSuperview()
                    self.view.userInteractionEnabled = true
                }.addDisposableTo(self.disposeBag)

        }
        
        alert.addAction(updateAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    func showExitAlert(title: String, msg: String){
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
