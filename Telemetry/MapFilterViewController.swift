//
//  MapFilterViewController.swift
//  Telemetry
//
//  Created by Agentum on 01.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MapFilterViewController: UIViewController {
    let HEADER_CELL_ID = "headerCell"
    let FILTER_CELL_ID = "filterCell"
    
    let SELECT_SEGUE_IDENTIFIER = "selectSegueID"
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var table: UITableView!
    
    let disposeBag = DisposeBag()
    
    var filterClient: VehiclesFilterClient?
    var filterViewModel: VehiclesFilterViewModel?
    
    var filterDict: FilterDict?
    
    var indicator: UIActivityIndicatorView?
    
    enum RowType: Int{
        case company = 1
        case autoModel = 3
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterClient = VehiclesFilterClient(_token: ApplicationState.sharedInstance.getToken() ?? "")
        filterViewModel = VehiclesFilterViewModel(filterClient: filterClient!)
        
        adjustSearchBar()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if(self.filterDict == nil){
            self.indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            self.indicator?.center = self.view.center
            self.view.addSubview(self.indicator!)
            self.indicator!.startAnimating()
            addBindsToViewModel()
        }
    }
    
    
    func adjustSearchBar(){
        self.searchBar.isHidden = true
        self.searchBar.text = (PreferencesManager.showGarageNumber()) ? (ApplicationState.sharedInstance.filter?.garageNumber ?? "") : (ApplicationState.sharedInstance.filter?.registrationNumber ?? "")
        self.searchBar.placeholder = (PreferencesManager.showGarageNumber()) ? "Гаражный номер ТС" : "Регистрационный номер ТС"
    }
    
    func addBindsToViewModel(){
        filterViewModel?.filterDict.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self](filtDict) in
                self.filterDict = filtDict
                self.indicator!.stopAnimating()
                self.searchBar.isHidden = false
                self.addTableBinds()
                }, onError: { (err) in
                self.showAlert("Ошибка", msg: "Произошла ошибка при загрузке фильтра")
            }, onCompleted: { 
                
            }, onDisposed: { 
                
        }).addDisposableTo(self.disposeBag)
    }
    
    func addTableBinds(){
        let items = Observable.just([
            (name: "ВЫБРАТЬ ОРГАНИЗАЦИЮ", cellID: HEADER_CELL_ID),
            (name: "Организация", cellID: FILTER_CELL_ID),
            (name: "ВЫБРАТЬ МОДЕЛЬ ТС", cellID: HEADER_CELL_ID),
            (name: "Модель ТС", cellID: FILTER_CELL_ID)
            ])
        
        items.observeOn(MainScheduler.instance)
            .bindTo(table.rx.items){ [unowned self](tableView, row, element) in
                let indexPath = IndexPath(item: row, section: 0)
                let cell = self.table.dequeueReusableCell(withIdentifier: element.cellID, for: indexPath) as! CommonCell
                cell.mainText.text = element.name
                return cell
            }.addDisposableTo(self.disposeBag)
        
        table.rx.itemSelected.observeOn(MainScheduler.instance)
        .subscribe({ [unowned self](event) in
            guard let indexPath = event.element else { return }
            if (self.filterDict != nil){
                if((indexPath as NSIndexPath).row == RowType.company.rawValue){
                    self.performSegue(withIdentifier: self.SELECT_SEGUE_IDENTIFIER, sender: NSNumber(value: RowType.company.rawValue as Int))
                } else if((indexPath as NSIndexPath).row == RowType.autoModel.rawValue){
                    self.performSegue(withIdentifier: self.SELECT_SEGUE_IDENTIFIER, sender: NSNumber(value: RowType.autoModel.rawValue as Int))
                }
            }
        })
        .addDisposableTo(self.disposeBag)
    }
    
    //MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == SELECT_SEGUE_IDENTIFIER){
            if let rowType = RowType(rawValue: (sender as! NSNumber).intValue){
                if let destVC = segue.destination as? SelectableTableViewController{
                    if(rowType == RowType.company){
                        destVC.selectType = .company
                        destVC.companies = filterDict?.companies ?? []
                        destVC.selectedIds = ApplicationState.sharedInstance.filter?.companyIds ?? []
                    } else if(rowType == RowType.autoModel){
                        destVC.selectType = .autoModel
                        destVC.autoModels = filterDict?.models ?? []
                        destVC.selectedIds = ApplicationState.sharedInstance.filter?.autoModelIds ?? []
                    }
                }
            }
        }
     }
    

    //MARK: IBActions
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func applyFilter(_ sender: AnyObject) {
        
        if(!PreferencesManager.showGarageNumber()){
            if(self.searchBar.text != nil){
                ApplicationState.sharedInstance.filter?.registrationNumber = self.searchBar.text!
            }
        } else {
            if(self.searchBar.text != nil){
                ApplicationState.sharedInstance.filter?.garageNumber = self.searchBar.text!
            }
        }

        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clearFilter(_ sender: AnyObject) {
        let alert = UIAlertController(title: "",
                                      message: "Очистить параметры фильтра?",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "Отмена",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
        let clearAction = UIAlertAction(title: "ОК", style: .default) { (action) in
             ApplicationState.sharedInstance.filter = Filter()
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(clearAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: Alerts
    func showAlert(_ title: String, msg: String){
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
