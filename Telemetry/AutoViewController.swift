//
//  AutoViewController.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//


import UIKit
import RxCocoa
import RxSwift


class AutoViewController: UIViewController {
    
    @IBOutlet var companyName: UILabel!
    
    var autoId: Int64?
    var viewModel :AutoViewModel?
    var autoClient: AutoClient?
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoClient = AutoClient(_token: ApplicationState.sharedInstance().getToken() ?? "", _autoId: autoId ?? 0)
        self.viewModel = AutoViewModel(autoClient: autoClient!)
        
        addBindsToViewModel()
        
    }
    
    func addBindsToViewModel(){
        
        self.viewModel?.auto
            .observeOn(MainScheduler.instance)
            .map({ (auto) -> String in
                return "\(auto.registrationNumber ?? "")"
            }).bindTo(self.companyName.rx_text)
            .addDisposableTo(self.disposeBag)
        
    }
    
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
