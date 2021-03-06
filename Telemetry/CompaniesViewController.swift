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


class CompaniesViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet var table: UITableView!
    

    let COMPANY_DETAIL_SEGUE = "companyDetailSegue"
    let CELL_IDENTIFIER = "companyCellIdentifier"
    
    var viewModel :CompaniesViewModel?
    var companiesClient = CompaniesClient(_token: ApplicationState.sharedInstance().getToken() ?? "")
    let disposeBag = DisposeBag()
    
    var publishSubject = PublishSubject<[Company]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        companiesClient.filter = ApplicationState.sharedInstance().filter
        self.viewModel = CompaniesViewModel(_companiesClient: companiesClient)
        
        addBindsToViewModel()
        addTableBinds()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
     
        self.viewModel?.getCompaniesObservable()
        .doOnError({ (errType) in
            
        })
        .subscribeNext({ (companies) in
            self.publishSubject.onNext(companies)
        })
        .addDisposableTo(self.disposeBag)
    }
    
    func addBindsToViewModel(){

        self.publishSubject
            .observeOn(MainScheduler.instance)
            .bindTo(table.rx_itemsWithCellFactory) { [unowned self](collectionView, row, element) in
                let indexPath = NSIndexPath(forItem: row, inSection: 0)
                let cell = self.table.dequeueReusableCellWithIdentifier(self.CELL_IDENTIFIER, forIndexPath: indexPath) as! CompanyTableCell
                cell.name.text = element.name ?? ""
                return cell
            }.addDisposableTo(self.disposeBag)
        
    }
    
    func addTableBinds(){
        
        self.table.rx_modelSelected(Company)
            .observeOn(MainScheduler.instance)
            .subscribeNext { [unowned self](company) in
                if let companyId = company.id{
                    self.performSegueWithIdentifier(self.COMPANY_DETAIL_SEGUE, sender: NSNumber(longLong: companyId))
                }
        }.addDisposableTo(self.disposeBag)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == COMPANY_DETAIL_SEGUE){
            if let destVC = segue.destinationViewController as? CompanyViewController{
                if let companyId = sender as? NSNumber{
                    destVC.companyId = companyId.longLongValue
                }
            }
        }
    }
    
    @IBAction func menuPressed(sender: AnyObject) {
        ApplicationState.sharedInstance().showLeftPanel()
    }
    
    func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .Cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
}
