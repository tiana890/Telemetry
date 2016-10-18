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
    
    @IBOutlet var showRegistrationNumber: UILabel!
    
    //MARK: Rx Entities
    
    let disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if(PreferencesManager.showGarageNumber()){
            self.showRegistrationNumber.text = "Отображать гаражные номера"
        } else {
            self.showRegistrationNumber.text = "Отображать регистрационные номера"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if((indexPath as NSIndexPath).row == 0){
            self.showAlert("Вы действительно хотите обновить справочники ТС?", msg: "Это займет некоторое время")
        } else if((indexPath as NSIndexPath).row == 4){
            self.showExitAlert("Вы действительно хотите выйти из приложения?", msg: "")
        }
    }
    
    //MARK: -IBActions
    
    @IBAction func menuPressed(_ sender: AnyObject) {
         ApplicationState.sharedInstance.showLeftPanel()
    }
    
    //MARK: -Alerts
    
    func showAlert(_ title: String, msg: String){
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Отмена",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        let updateAction = UIAlertAction(title: "OK", style: .default) { (action) in

            HUD.show(.labeledProgress(title: "Обновление справочника ТС", subtitle: "Это может занять некоторое время"))
            
            AutosClient(_token: ApplicationState.sharedInstance.getToken() ?? "")
                .autosDictJSONObservable()
                .observeOn(MainScheduler.instance)
                .doOnError(onError: { (errType) in
                    HUD.flash(.labeledError(title: "Ошибка", subtitle: "Не удалось обновить справочник ТС. Информация о ТС может отображаться некорректно."), delay: 2, completion: nil)
                })
                .subscribeNext { (autosDictResponse) in
                    HUD.flash(.success)
                }.addDisposableTo(self.disposeBag)

        }
        
        alert.addAction(updateAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showExitAlert(_ title: String, msg: String){
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
