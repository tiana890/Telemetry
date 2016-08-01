//
//  CompanyViewController.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class CompanyViewController: UIViewController {
    
    @IBOutlet var companyName: UILabel!
    
    var companyId: Int64?
    var viewModel :CompanyViewModel?
    var companyClient: CompanyClient?
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        companyClient = CompanyClient(_token: ApplicationState.sharedInstance().getToken() ?? "", _companyId: companyId ?? 0)
        self.viewModel = CompanyViewModel(companyClient: companyClient!)
        
        addBindsToViewModel()
        
    }
    
    func addBindsToViewModel(){
        
        self.viewModel?.company
            .observeOn(MainScheduler.instance)
            .map({ (company) -> String in
                return company.name ?? ""
            }).bindTo(self.companyName.rx_text)
            .addDisposableTo(self.disposeBag)
        
    }
    
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
