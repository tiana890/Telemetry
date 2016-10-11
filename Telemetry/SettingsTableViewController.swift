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
import PKHUD

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

            HUD.show(.LabeledProgress(title: "Обновление справочника ТС", subtitle: "Это может занять некоторое время"))
            
            AutosClient(_token: ApplicationState.sharedInstance().getToken() ?? "")
                .autosDictJSONObservable()
                .observeOn(MainScheduler.instance)
                .doOnError({ (errType) in
                    HUD.flash(.LabeledError(title: "Ошибка", subtitle: "Не удалось обновить справочник ТС. Информация о ТС может отображаться некорректно."), delay: 2, completion: nil)
                })
                .subscribeNext { (autosDictResponse) in
                    HUD.flash(.Success)
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
