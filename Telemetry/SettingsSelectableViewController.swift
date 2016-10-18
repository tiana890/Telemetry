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
        case RegistrationNumber
        case GarageNumber
    }
    
    let disposeBag = DisposeBag()

    
    let COMMON_CELL_IDENTIFIER = "commonCell"
    
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
            let indexPath = NSIndexPath(forItem: row, inSection: 0)
            let cell = self.table.dequeueReusableCellWithIdentifier(self.COMMON_CELL_IDENTIFIER, forIndexPath: indexPath) as! SelectableCell
            cell.mainText.text = element
            return cell
        }.addDisposableTo(disposeBag)
        
        table.rx_itemSelected
        .subscribeNext { (indexPath) in
            if(indexPath.row == ShowNumber.RegistrationNumber.rawValue){
                PreferencesManager.setShowGarageNumber(false)
            } else {
                PreferencesManager.setShowGarageNumber(true)
            }
            self.table.reloadData()
        }.addDisposableTo(self.disposeBag)
        
        table.rx_willDisplayCell.observeOn(MainScheduler.instance)
        .subscribeNext { [unowned self](event) in
            if(event.indexPath.row == ShowNumber.RegistrationNumber.rawValue){
                 event.cell.setSelected(!PreferencesManager.showGarageNumber(), animated: false)
            } else {
                event.cell.setSelected(PreferencesManager.showGarageNumber(), animated: false)
            }
        }.addDisposableTo(self.disposeBag)
    }
    
    
    @IBAction func applyPressed(sender: AnyObject) {

        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    

    
}

