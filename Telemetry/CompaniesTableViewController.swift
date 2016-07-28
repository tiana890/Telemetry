//
//  CompaniesTableViewController.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class CompaniesViewController: BaseViewController {
    
    //MARK: IBOutlets
    @IBOutlet var table: UITableView!
    
    let CELL_IDENTIFIER = "companyCellIdentifier"
    
    var viewModel :CompanyViewModel?
    var companiesClient = CompaniesClient(_token: ApplicationState.sharedInstance().token ?? "")
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = CompanyViewModel(companiesClient: companiesClient)
        
        addBindsToViewModel()
        
    }
    
    func addBindsToViewModel(){

        let sub = self.viewModel?.companies
            .observeOn(MainScheduler.instance)
            .bindTo(table.rx_itemsWithCellFactory) { [unowned self](collectionView, row, element) in
                let indexPath = NSIndexPath(forItem: row, inSection: 0)
                let cell = self.table.dequeueReusableCellWithIdentifier(self.CELL_IDENTIFIER, forIndexPath: indexPath) as! CompanyTableCell
                cell.name.text = element.name ?? ""
                return cell
            }
        addSubscription(sub!)
    }
}
