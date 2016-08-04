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
    
    let COMPANY_SELECT_SEGUE_ID = "companySelectSegueID"
    let AUTO_MODEL_SELECT_SEGUE_ID = "autoModelSelectSegueID"
    
    @IBOutlet var table: UITableView!
    let disposeBag = DisposeBag()
    
    var filterClient: VehiclesFilterClient?
    var filterViewModel: VehiclesFilterViewModel?
    
    var filterDict: FilterDict?
    
    enum RowType: Int{
        case Company = 2
        case AutoModel = 4
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterClient = VehiclesFilterClient(_token: ApplicationState.sharedInstance().getToken() ?? "")
        filterViewModel = VehiclesFilterViewModel(filterClient: filterClient!)
        
        addTableBinds()
        addBindsToViewModel()
    }
    
    func addBindsToViewModel(){
        filterViewModel?.filterDict.subscribeNext({ (filterDict) in
            print(filterDict)
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
                    self.performSegueWithIdentifier(self.COMPANY_SELECT_SEGUE_ID, sender: nil)
                } else if(indexPath.row == RowType.AutoModel.rawValue){
                    self.performSegueWithIdentifier(self.AUTO_MODEL_SELECT_SEGUE_ID, sender: nil)
                }
            }
        }.addDisposableTo(self.disposeBag)
    }
    
    //MARK: Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == COMPANY_SELECT_SEGUE_ID){
            if let destVC = segue.destinationViewController as? SelectableTableViewController{
                destVC.selectType = .Company
                destVC.companies = filterDict!.companies ?? []
            }
        } else if(segue.identifier == AUTO_MODEL_SELECT_SEGUE_ID){
            if let destVC = segue.destinationViewController as? SelectableTableViewController{
                destVC.selectType = .AutoModel
                destVC.autoModels = filterDict!.models ?? []
            }
        }
     }
    
    //MARK: IBActions
    
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func applyFilter(sender: AnyObject) {
    }
    
    @IBOutlet weak var clearFilter: UIBarButtonItem!
}
