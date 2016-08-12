//
//  CompanyFilterViewController.swift
//  Telemetry
//
//  Created by Agentum on 01.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CompanyFilterViewController: UIViewController {
    let HEADER_CELL_ID = "headerCell"
    let FILTER_CELL_ID = "filterCell"
    
    @IBOutlet var table: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.text = ApplicationState.sharedInstance().filter?.companyName ?? ""
        searchBar.rx_text.observeOn(MainScheduler.instance)
            .subscribeNext { (str) in
                ApplicationState.sharedInstance().filter?.companyName = str
        }.addDisposableTo(self.disposeBag)
        
        let items = Observable.just([
            (name: "ВЫБРАТЬ ОРГАНИЗАЦИЮ", cellID: HEADER_CELL_ID),
            (name: "Организация", cellID: FILTER_CELL_ID),
            (name: "ВЫБРАТЬ МОДЕЛЬ ТС", cellID: HEADER_CELL_ID),
            (name: "Модель ТС", cellID: FILTER_CELL_ID)
            ])
        
    }

    //MARK: IBActions
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func applyFilter(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func clearFilter(sender: AnyObject) {
        self.searchBar.text = ""
    }
}
