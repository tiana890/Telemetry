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
    
    @IBOutlet var searchBar: UISearchBar!
    
    enum SelectType{
        case Company
        case AutoModel
    }
    
    let disposeBag = DisposeBag()
    
    var companies = [Company]()
    var autoModels = [AutoModel]()

    var filterCompanies = PublishSubject<[Company]>()
    var filterAutoModels = PublishSubject<[AutoModel]>()
    
    var filterCompaniesArray = [Company]()
    var filterAutoModelsArray = [AutoModel]()
    
    var selectedIds = [Int]()
    
    var selectType: SelectType = .Company
    
    let COMMON_CELL_IDENTIFIER = "commonCell"

    @IBOutlet var headerName: UILabel!
    @IBOutlet var table: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerName.text = (self.selectType == .Company) ? "Организация" : "Модель ТС"
        createObservables()
        addTableBinds()
        adjustSearchBar()
        
        filterCompanies.onNext(companies)
        filterAutoModels.onNext(autoModels)
        
        self.filterCompaniesArray = companies
        self.filterAutoModelsArray = autoModels
        
        setObservers()
    }
    
    func createObservables(){
        if(selectType == .Company){
            self.filterCompanies.asObservable().bindTo(table.rx_itemsWithCellFactory){ [unowned self](tableView, row, element) in
                let indexPath = NSIndexPath(forItem: row, inSection: 0)
                let cell = self.table.dequeueReusableCellWithIdentifier(self.COMMON_CELL_IDENTIFIER, forIndexPath: indexPath) as! SelectableCell
                cell.mainText.text = element.name
                return cell
            }.addDisposableTo(self.disposeBag)
        } else if(selectType == .AutoModel){
            self.filterAutoModels.asObservable().bindTo(table.rx_itemsWithCellFactory){ [unowned self](tableView, row, element) in
                let indexPath = NSIndexPath(forItem: row, inSection: 0)
                let cell = self.table.dequeueReusableCellWithIdentifier(self.COMMON_CELL_IDENTIFIER, forIndexPath: indexPath) as! SelectableCell
                cell.mainText.text = element.name
                return cell
            }.addDisposableTo(self.disposeBag)
        }
    }
    
    func addTableBinds(){
        if(self.selectType == .Company){
            table.rx_modelSelected(Company)
            .subscribeNext({ (company) in
                if let itemId = company.id{
                    if let index = self.selectedIds.indexOf(itemId){
                        self.selectedIds.removeAtIndex(index)
                    } else {
                        self.selectedIds.append(itemId)
                    }
                }
                self.table.reloadData()
            }).addDisposableTo(self.disposeBag)
        } else {
            table.rx_modelSelected(AutoModel)
                .subscribeNext({ (autoModel) in
                    if let itemId = autoModel.id{
                        if let index = self.selectedIds.indexOf(itemId){
                            self.selectedIds.removeAtIndex(index)
                        } else {
                            self.selectedIds.append(itemId)
                        }
                    }
                    self.table.reloadData()
                }).addDisposableTo(self.disposeBag)
            
        }
        
        
        table.rx_willDisplayCell.observeOn(MainScheduler.instance)
             .subscribeNext { [unowned self](event) in
                if let itemId = (self.selectType == .Company) ? self.filterCompaniesArray[event.indexPath.row].id :  self.filterAutoModelsArray[event.indexPath.row].id {
                    if(self.selectedIds.contains(itemId)){
                        event.cell.setSelected(true, animated: false)
                    } else {
                        event.cell.setSelected(false, animated: false)
                    }
                }
            }.addDisposableTo(self.disposeBag)
    }
    
    func adjustSearchBar(){
        self.searchBar
        .rx_text
        .debounce(0.4, scheduler: MainScheduler.instance)
        .subscribeNext { (str) in
            guard str.characters.count > 0 else {
                if(self.selectType == .Company){
                    self.filterCompaniesArray.removeAll()
                    self.filterCompaniesArray.appendContentsOf(self.companies)
                    self.filterCompanies.onNext(self.companies)
                } else {
                    self.filterAutoModelsArray.removeAll()
                    self.filterAutoModelsArray.appendContentsOf(self.autoModels)
                    self.filterAutoModels.onNext(self.autoModels)
                }
                return
            }
            if (self.selectType == .Company){
                let arr = self.companies.filter({ (company) -> Bool in
                    if let name = company.name{
                        if(name.lowercaseString.containsString(str.lowercaseString)){
                            return true
                        }
                    }
                    return false
                })
                self.filterCompaniesArray.removeAll()
                self.filterCompaniesArray.appendContentsOf(arr)
                self.filterCompanies.on(.Next(arr))
            } else {
                let arr = self.autoModels.filter({ (autoModel) -> Bool in
                    if let name = autoModel.name{
                        if(name.lowercaseString.containsString(str.lowercaseString)){
                            return true
                        }
                    }
                    return false
                })
                self.filterAutoModelsArray.removeAll()
                self.filterAutoModelsArray.appendContentsOf(arr)
                self.filterAutoModels.on(.Next(arr))
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
    
    func setObservers(){
        
        NSNotificationCenter.defaultCenter().rx_notification(UIKeyboardWillShowNotification).observeOn(MainScheduler.instance).subscribeNext { [unowned self](notification) in
            let keyboardFrame: CGRect = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
                self.table.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrame.size.height, 0)
            }.addDisposableTo(self.disposeBag)
        
        NSNotificationCenter.defaultCenter().rx_notification(UIKeyboardWillHideNotification).observeOn(MainScheduler.instance).subscribeNext { [unowned self](notification) in
                self.table.contentInset = UIEdgeInsetsZero
            }.addDisposableTo(self.disposeBag)
        
    }

}
