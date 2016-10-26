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
        case company
        case autoModel
    }
    
    let disposeBag = DisposeBag()
    
    var companies = [Company]()
    var autoModels = [AutoModel]()

    var filterCompanies = PublishSubject<[Company]>()
    var filterAutoModels = PublishSubject<[AutoModel]>()
    
    var filterCompaniesArray = [Company]()
    var filterAutoModelsArray = [AutoModel]()
    
    var selectedIds = [Int]()
    
    var selectType: SelectType = .company
    
    let COMMON_CELL_IDENTIFIER = "commonCell"

    @IBOutlet var headerName: UILabel!
    @IBOutlet var table: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerName.text = (self.selectType == .company) ? "Организация" : "Модель ТС"
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
        if(selectType == .company){
            self.filterCompanies.asObservable().bindTo(table.rx.items){ [unowned self](tableView, row, element) in
                let indexPath = IndexPath(item: row, section: 0)
                let cell = self.table.dequeueReusableCell(withIdentifier: self.COMMON_CELL_IDENTIFIER, for: indexPath) as! SelectableCell
                cell.mainText.text = element.name
                return cell
            }.addDisposableTo(self.disposeBag)
        } else if(selectType == .autoModel){
            self.filterAutoModels.asObservable().bindTo(table.rx.items){ [unowned self](tableView, row, element) in
                let indexPath = IndexPath(item: row, section: 0)
                let cell = self.table.dequeueReusableCell(withIdentifier: self.COMMON_CELL_IDENTIFIER, for: indexPath) as! SelectableCell
                cell.mainText.text = element.name
                return cell
            }.addDisposableTo(self.disposeBag)
        }
    }
    
    func addTableBinds(){
        if(self.selectType == .company){
            table.rx.modelSelected(Company)
            .subscribe({ (event) in
                guard let company = event.element else { return }
                if let itemId = company.id{
                    if let index = self.selectedIds.index(of: itemId){
                        self.selectedIds.remove(at: index)
                    } else {
                        self.selectedIds.append(itemId)
                    }
                }
                self.table.reloadData()
            })
                .addDisposableTo(self.disposeBag)
        } else {
            table.rx.modelSelected(AutoModel)
            .subscribe({ (event) in
                guard let autoModel = event.element else { return }
                if let itemId = autoModel.id{
                    if let index = self.selectedIds.index(of: itemId){
                        self.selectedIds.remove(at: index)
                    } else {
                        self.selectedIds.append(itemId)
                    }
                }
                self.table.reloadData()
            })
            .addDisposableTo(self.disposeBag)
            
        }
        
        
        table.rx.willDisplayCell.observeOn(MainScheduler.instance)
            .subscribe({ [unowned self](event) in
                guard let willDisplayCellEvent = event.element else { return }
                
                if let itemId = (self.selectType == .company) ? self.filterCompaniesArray[(willDisplayCellEvent.indexPath as NSIndexPath).row].id :  self.filterAutoModelsArray[(willDisplayCellEvent.indexPath as NSIndexPath).row].id {
                    if(self.selectedIds.contains(itemId)){
                        willDisplayCellEvent.cell.setSelected(true, animated: false)
                    } else {
                        willDisplayCellEvent.cell.setSelected(false, animated: false)
                    }
                }
            }).addDisposableTo(self.disposeBag)
    }
    
    func adjustSearchBar(){
        self.searchBar
        .rx.text
        .debounce(0.4, scheduler: MainScheduler.instance)
        .subscribe({ (event) in
            guard let strOpt = event.element else { return }
            guard let str = strOpt else { return }
            guard str.characters.count > 0 else {
                if(self.selectType == .company){
                    self.filterCompaniesArray.removeAll()
                    self.filterCompaniesArray.append(contentsOf: self.companies)
                    self.filterCompanies.onNext(self.companies)
                } else {
                    self.filterAutoModelsArray.removeAll()
                    self.filterAutoModelsArray.append(contentsOf: self.autoModels)
                    self.filterAutoModels.onNext(self.autoModels)
                }
                return
            }
            if (self.selectType == .company){
                let arr = self.companies.filter({ (company) -> Bool in
                    if let name = company.name{
                        if(name.lowercased().contains(str.lowercased())){
                            return true
                        }
                    }
                    return false
                })
                self.filterCompaniesArray.removeAll()
                self.filterCompaniesArray.append(contentsOf: arr)
                self.filterCompanies.on(.next(arr))
            } else {
                let arr = self.autoModels.filter({ (autoModel) -> Bool in
                    if let name = autoModel.name{
                        if(name.lowercased().contains(str.lowercased())){
                            return true
                        }
                    }
                    return false
                })
                self.filterAutoModelsArray.removeAll()
                self.filterAutoModelsArray.append(contentsOf: arr)
                self.filterAutoModels.on(.next(arr))
            }

        }).addDisposableTo(self.disposeBag)
    }
    
    @IBAction func applyFilter(_ sender: AnyObject) {
        if(self.selectType == SelectType.company){
            ApplicationState.sharedInstance.filter?.companyIds = self.selectedIds
        } else if(self.selectType == SelectType.autoModel){
            ApplicationState.sharedInstance.filter?.autoModelIds = self.selectedIds
        }
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setObservers(){
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillShow).observeOn(MainScheduler.instance)
            .subscribe({ (event) in
                guard let notification = event.element else { return }
                let keyboardFrame: CGRect = ((notification as NSNotification).userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
                self.table.contentInset = UIEdgeInsetsMake(0, 0, keyboardFrame.size.height, 0)
            }).addDisposableTo(self.disposeBag)
        
        NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide).observeOn(MainScheduler.instance)
            .subscribe({ [unowned self](event) in
                guard let notification = event.element else { return }
                self.table.contentInset = UIEdgeInsets.zero
            }).addDisposableTo(self.disposeBag)
        
    }

}
