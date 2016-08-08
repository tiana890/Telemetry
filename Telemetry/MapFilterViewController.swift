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
    
    @IBOutlet var table: UITableView!
    let disposeBag = DisposeBag()
    
    var filterClient: VehiclesFilterClient?
    var filterViewModel: VehiclesFilterViewModel?
    
    var filterDict: FilterDict?
    
    enum RowType: Int{
        case Company = 1
        case AutoModel = 3
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterClient = VehiclesFilterClient(_token: ApplicationState.sharedInstance().getToken() ?? "")
        filterViewModel = VehiclesFilterViewModel(filterClient: filterClient!)
        
        addTableBinds()
        addBindsToViewModel()
    }
    
    func addBindsToViewModel(){
        filterViewModel?.filterDict.observeOn(MainScheduler.instance).subscribeNext({ [unowned self](filtDict) in
            self.filterDict = filtDict
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
            .bindTo(table.rx_itemsWithCellFactory){ [unowned self](tableView, row, element) in
                let indexPath = NSIndexPath(forItem: row, inSection: 0)
                let cell = self.table.dequeueReusableCellWithIdentifier(element.cellID, forIndexPath: indexPath) as! CommonCell
                cell.mainText.text = element.name
                return cell
            }.addDisposableTo(self.disposeBag)
        
        table.rx_itemSelected.observeOn(MainScheduler.instance)
        .subscribeNext { [unowned self](indexPath) in
            if (self.filterDict != nil){
                if(indexPath.row == RowType.Company.rawValue){
                    self.performSegueWithIdentifier(self.SELECT_SEGUE_IDENTIFIER, sender: NSNumber(integer:RowType.Company.rawValue))
                } else if(indexPath.row == RowType.AutoModel.rawValue){
                    self.performSegueWithIdentifier(self.SELECT_SEGUE_IDENTIFIER, sender: NSNumber(integer:RowType.AutoModel.rawValue))
                }
            }
        }.addDisposableTo(self.disposeBag)
    }
    
    //MARK: Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == SELECT_SEGUE_IDENTIFIER){
            if let rowType = RowType(rawValue: (sender as! NSNumber).integerValue){
                if let destVC = segue.destinationViewController as? SelectableTableViewController{
                    if(rowType == RowType.Company){
                        destVC.selectType = .Company
                        destVC.companies = filterDict!.companies ?? []
                        destVC.selectedIds = ApplicationState.sharedInstance().filter!.companyIds
                    } else if(rowType == RowType.AutoModel){
                        destVC.selectType = .AutoModel
                        destVC.autoModels = filterDict!.models ?? []
                        destVC.selectedIds = ApplicationState.sharedInstance().filter!.autoModelIds
                    }
                }
            }
        }
     }
    
    override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }
    //MARK: IBActions
    
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func applyFilter(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBOutlet weak var clearFilter: UIBarButtonItem!
}
