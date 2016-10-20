//
//  SelectableTableViewController.swift
//  Telemetry
//
//  Created by IMAC  on 04.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsSelectableViewController: UIViewController {
    
    enum ShowNumber: Int{
        case registrationNumber
        case garageNumber
    }
    
    let disposeBag = DisposeBag()

    
    let COMMON_CELL_IDENTIFIER = "commonCell"
    
    var showGarageNumber = PreferencesManager.showGarageNumber()
    
    @IBOutlet var headerName: UILabel!
    @IBOutlet var table: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerName.text = "Отображение номера"
        addTableBinds()

    }
    
    func addTableBinds(){
        
        let array = Observable.just(["Отображать регистрационные номера", "Отображать гаражные номера"])
        
        array.asObservable()
        .bindTo(table.rx_itemsWithCellFactory){ [unowned self](tableView, row, element) in
            let indexPath = IndexPath(item: row, section: 0)
            let cell = self.table.dequeueReusableCell(withIdentifier: self.COMMON_CELL_IDENTIFIER, for: indexPath) as! SelectableCell
            cell.mainText.text = element
            return cell
        }.addDisposableTo(disposeBag)
        
        table.rx.itemSelected
        .subscribeNext { (indexPath) in
            if((indexPath as NSIndexPath).row == ShowNumber.registrationNumber.rawValue){
                self.showGarageNumber = false
            } else {
                self.showGarageNumber = true
            }
            self.table.reloadData()
        }.addDisposableTo(self.disposeBag)
        
        table.rx.willDisplayCell.observeOn(MainScheduler.instance)
        .subscribeNext { [unowned self](event) in
            if((event.indexPath as NSIndexPath).row == ShowNumber.registrationNumber.rawValue){
                 event.cell.setSelected(!self.showGarageNumber, animated: false)
            } else {
                event.cell.setSelected(self.showGarageNumber, animated: false)
            }
        }.addDisposableTo(self.disposeBag)
    }
    
    
    @IBAction func applyPressed(_ sender: AnyObject) {
        if(!PreferencesManager.showGarageNumber() == self.showGarageNumber){
            if(!self.showGarageNumber){
                ApplicationState.sharedInstance.filter?.registrationNumber = ""
            } else {
                ApplicationState.sharedInstance.filter?.garageNumber = ""
            }
            PreferencesManager.setShowGarageNumber(self.showGarageNumber)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    

    
}

