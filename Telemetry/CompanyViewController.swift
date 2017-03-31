//
//  CompanyViewController.swift
//  TeleFilterCellmetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class CompanyViewController: UIViewController {
    
    let HEADER_CELL_IDENTIFIER = "headerCell"
    let COMMON_CELL_IDENTIFIER = "commonCell"
    
    @IBOutlet var table: UITableView!
    
    var companyId: Int64?
    var viewModel :CompanyViewModel?
    var companyClient: CompanyClient?
    
    let disposeBag = DisposeBag()
    var items = Observable<[(cellID:String, name: String)]>.empty()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.tag = 12345
        indicator.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        indicator.startAnimating()
        self.view.addSubview(indicator)
        self.table.isHidden = true
        
        companyClient = CompanyClient(_token: ApplicationState.sharedInstance.getToken() ?? "", _companyId: companyId ?? 0)
        self.viewModel = CompanyViewModel(companyClient: companyClient!)
        addBindsToViewModel()
        
    }
    
    func addBindsToViewModel(){
        
        self.viewModel?.company
            .observeOn(MainScheduler.instance)
            .do(onError: { (err) in
                self.showAlert("Ошибка", msg: "Невозможно загрузить данные")
            })
            .flatMap({ [unowned self](company) -> Observable<[(cellID:String, name: String)]> in
                self.view.viewWithTag(12345)?.removeFromSuperview()
                self.table.isHidden = false
                return Observable.just(self.createItemsArrayFromCompanyModel(company))
            }).bindTo(table.rx.items){ [unowned self](tableView, row, element) in
                
                let indexPath = IndexPath(item: row, section: 0)
                let cell = self.table.dequeueReusableCell(withIdentifier: element.cellID, for: indexPath) as! CommonCell
                cell.mainText.text = element.name
                return cell
            }.addDisposableTo(self.disposeBag)
        
    }
    
    func createItemsArrayFromCompanyModel(_ company: Company) -> [(cellID:String, name: String)]{
        var array = [(cellID:String, name: String)]()
        
        array.append((self.HEADER_CELL_IDENTIFIER, "Название"))
        array.append((self.COMMON_CELL_IDENTIFIER, company.name ?? ""))
        array.append((self.HEADER_CELL_IDENTIFIER, "Адрес"))
        array.append((self.COMMON_CELL_IDENTIFIER, company.address ?? ""))
        array.append((self.HEADER_CELL_IDENTIFIER, "Телефон"))
        array.append((self.COMMON_CELL_IDENTIFIER, company.phone ?? ""))
        
        return array
    }
    
    //MARK: -Alerts
    func showAlert(_ title: String, msg: String){
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }

    
    
    //MARK: IBActions
    @IBAction func menuPressed(_ sender: AnyObject) {
        ApplicationState.sharedInstance.showLeftPanel()
    }
    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
}
