//
//  VehiclesViewController.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift


class AutosViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet var collection:  UICollectionView!
    
    let COMPANY_DETAIL_SEGUE = "autoDetailSegue"
    let CELL_IDENTIFIER = "autoCollectionCell"
    
    var viewModel:AutosViewModel?
    var autosClient:AutosClient?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autosClient = AutosClient(_token: ApplicationState.sharedInstance().token ?? "")
        self.viewModel = AutosViewModel(autosClient: autosClient!)
        
        addBindsToViewModel()
        //addCollectionBinds()
    }
    
    func addBindsToViewModel(){
        
        self.viewModel?.autos
            .observeOn(MainScheduler.instance)
            .bindTo(collection.rx_itemsWithCellFactory) { [unowned self](collectionView, row, element) in
                let indexPath = NSIndexPath(forItem: row, inSection: 0)
                let cell = self.collection.dequeueReusableCellWithReuseIdentifier(self.CELL_IDENTIFIER, forIndexPath: indexPath) as! AutoCollectionCell
                
                return cell
            }.addDisposableTo(self.disposeBag)
        
    }
    
    func addCollectionBinds(){
        
//        self.table.rx_modelSelected(Company)
//            .observeOn(MainScheduler.instance)
//            .subscribeNext { [unowned self](company) in
//                if let companyId = company.id{
//                    self.performSegueWithIdentifier(self.COMPANY_DETAIL_SEGUE, sender: NSNumber(longLong: companyId))
//                }
//            }.addDisposableTo(self.disposeBag)
        
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if(segue.identifier == COMPANY_DETAIL_SEGUE){
//            if let destVC = segue.destinationViewController as? CompanyViewController{
//                if let companyId = sender as? NSNumber{
//                    destVC.companyId = companyId.longLongValue
//                }
//            }
//        }
//    }
    
    @IBAction func menuPressed(sender: AnyObject) {
        ApplicationState.sharedInstance().showLeftPanel()
    }
}
