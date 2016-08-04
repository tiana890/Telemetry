//
//  SelectableTableViewController.swift
//  Telemetry
//
//  Created by IMAC  on 04.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SelectableTableViewController: UIViewController {
    
    enum SelectType{
        case Company
        case AutoModel
    }
    
    let disposeBag = DisposeBag()
    
    var companies = [Company]()
    var autoModels = [AutoModel]()
    
    var selectType: SelectType = .Company
    
    let COMMON_CELL_IDENTIFIER = "commonCell"

    @IBOutlet var headerName: UILabel!
    
    @IBOutlet var table: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        createObservables()
    }
    
    func createObservables(){
        if(selectType == .Company){
            Observable.just(companies).bindTo(table.rx_itemsWithCellFactory){ [unowned self](tableView, row, element) in
                let indexPath = NSIndexPath(forItem: row, inSection: 0)
                let cell = self.table.dequeueReusableCellWithIdentifier(self.COMMON_CELL_IDENTIFIER, forIndexPath: indexPath) as! CommonCell
                cell.mainText.text = element.name
                return cell
            }.addDisposableTo(self.disposeBag)
        } else if(selectType == .AutoModel){
            Observable.just(autoModels).bindTo(table.rx_itemsWithCellFactory){ [unowned self](tableView, row, element) in
                let indexPath = NSIndexPath(forItem: row, inSection: 0)
                let cell = self.table.dequeueReusableCellWithIdentifier(self.COMMON_CELL_IDENTIFIER, forIndexPath: indexPath) as! CommonCell
                cell.mainText.text = element.name
                return cell
            }.addDisposableTo(self.disposeBag)
        }
    }
    
}
