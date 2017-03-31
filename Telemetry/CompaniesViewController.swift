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
    
    var viewModel:CompaniesViewModel?
    var companiesClient = CompaniesClient(_token: ApplicationState.sharedInstance.getToken() ?? "")
    let disposeBag = DisposeBag()
    
    var companiesLoaded = false
    var publishSubject = PublishSubject<[Company]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        companiesClient.filter = ApplicationState.sharedInstance.filter
        self.viewModel = CompaniesViewModel(_companiesClient: companiesClient)
        
        addBindsToViewModel()
        addTableBinds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard !companiesLoaded else { return }
     
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        indicator.startAnimating()
        self.view.addSubview(indicator)
        self.table.isHidden = true
        
        self.viewModel?.getCompaniesObservable()
        .subscribe({ (event) in
            if(event.error != nil){
                DispatchQueue.main.async(execute: {
                    indicator.removeFromSuperview()
                    self.table.isHidden = false
                })
                self.showAlert("Ошибка", msg: "Невозможно загрузить данные")
            } else {
                guard let companies = event.element else { return }
                DispatchQueue.main.async(execute: {
                    indicator.removeFromSuperview()
                    self.table.isHidden = false
                    self.companiesLoaded = true
                })
                self.publishSubject.onNext(companies)
            }
        }).addDisposableTo(self.disposeBag)
    }
    
    func addBindsToViewModel(){

        self.publishSubject
            .observeOn(MainScheduler.instance)
            .bindTo(table.rx.items) { [unowned self](collectionView, row, element) in
                let indexPath = IndexPath(item: row, section: 0)
                let cell = self.table.dequeueReusableCell(withIdentifier: self.CELL_IDENTIFIER, for: indexPath) as! CompanyTableCell
                cell.name.text = element.name ?? ""
                return cell
            }.addDisposableTo(self.disposeBag)
        
    }
    
    func addTableBinds(){
        
        self.table.rx.modelSelected(Company.self)
            .observeOn(MainScheduler.instance)
            .subscribe({ [unowned self](event) in
                guard let company = event.element else { return }
                if let companyId = company.id{
                    self.performSegue(withIdentifier: self.COMPANY_DETAIL_SEGUE, sender: NSNumber(value: companyId as Int))
                }
        }).addDisposableTo(self.disposeBag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == COMPANY_DETAIL_SEGUE){
            if let destVC = segue.destination as? CompanyViewController{
                if let companyId = sender as? NSNumber{
                    destVC.companyId = companyId.int64Value
                }
            }
        }
    }
    
    @IBAction func menuPressed(_ sender: AnyObject) {
        ApplicationState.sharedInstance.showLeftPanel()
    }
    
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
