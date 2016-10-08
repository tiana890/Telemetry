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

class SelectableTableViewController: UIViewController {
    
    enum SelectType{
        case Company
        case AutoModel
    }
    
    let disposeBag = DisposeBag()
    
    var companies = [Company]()
    var autoModels = [AutoModel]()
    
    var selectedIds = [Int64]()
    
    var selectType: SelectType = .Company
    
    let COMMON_CELL_IDENTIFIER = "commonCell"

    @IBOutlet var headerName: UILabel!
    @IBOutlet var table: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerName.text = (self.selectType == .Company) ? "Организация" : "Модель ТС"
        
        createObservables()
        addTableBinds()
    }
    
    func createObservables(){
        if(selectType == .Company){
            Observable.just(companies).bindTo(table.rx_itemsWithCellFactory){ [unowned self](tableView, row, element) in
                let indexPath = NSIndexPath(forItem: row, inSection: 0)
                let cell = self.table.dequeueReusableCellWithIdentifier(self.COMMON_CELL_IDENTIFIER, forIndexPath: indexPath) as! SelectableCell
                cell.mainText.text = element.name
                return cell
            }.addDisposableTo(self.disposeBag)
        } else if(selectType == .AutoModel){
            Observable.just(autoModels).bindTo(table.rx_itemsWithCellFactory){ [unowned self](tableView, row, element) in
                let indexPath = NSIndexPath(forItem: row, inSection: 0)
                let cell = self.table.dequeueReusableCellWithIdentifier(self.COMMON_CELL_IDENTIFIER, forIndexPath: indexPath) as! SelectableCell
                cell.mainText.text = element.name
                return cell
            }.addDisposableTo(self.disposeBag)
        }
    }
    
    func addTableBinds(){
        table.rx_itemSelected.observeOn(MainScheduler.instance)
             .subscribeNext { [unowned self](ip) in
                if let itemId = (self.selectType == .Company) ? self.companies[ip.row].id :  self.autoModels[ip.row].id {
                    if let index = self.selectedIds.indexOf(itemId){
                        self.selectedIds.removeAtIndex(index)
                    } else {
                        self.selectedIds.append(itemId)
                    }
                    self.table.reloadRowsAtIndexPaths([ip], withRowAnimation: UITableViewRowAnimation.None)
                }
                
            }.addDisposableTo(self.disposeBag)
        
        
        table.rx_willDisplayCell.observeOn(MainScheduler.instance)
             .subscribeNext { [unowned self](event) in
                print(self.selectedIds)
                if let itemId = (self.selectType == .Company) ? self.companies[event.indexPath.row].id :  self.autoModels[event.indexPath.row].id {
                    if(self.selectedIds.contains(itemId)){
                        event.cell.setSelected(true, animated: false)
                    } else {
                        event.cell.setSelected(false, animated: false)
                    }
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    @IBAction func applyFilter(sender: AnyObject) {
        if(self.selectType == SelectType.Company){
            ApplicationState.sharedInstance().filter?.companyIds = self.selectedIds
        } else if(self.selectType == SelectType.AutoModel){
            ApplicationState.sharedInstance().filter?.autoModelIds = self.selectedIds
        }
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
