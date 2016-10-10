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
import QuartzCore
import SwiftyJSON

class AutosViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet var collection:  UICollectionView!
    @IBOutlet var filterView: UIView!
    
    let FILTER_STORYBOARD_ID = "FilterStoryboardID"
    
    let AUTO_DETAIL_SEGUE = "autoDetailSegue"
    let CELL_IDENTIFIER = "autoCollectionCell"
    
    var viewModel:AutosViewModel?
    var publishSubject = PublishSubject<[Auto]>()
    let disposeBag = DisposeBag()
    
    var storedFilter = Filter.createCopy(ApplicationState.sharedInstance().filter)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addCollectionBinds()
        addBindsToViewModel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        print(self.storedFilter)
        guard let f = self.storedFilter else {
            self.loadAutos(false)
            return
        }
        guard f.filterIsSet() else {
            self.loadAutos(false)
            return
        }
        
        if(!f.isEqualToFilter(ApplicationState.sharedInstance().filter)){
            let autosClient = AutosClient(_token: PreferencesManager.getToken() ?? "")
            autosClient.autosIDsObservableWithFilter()
                .observeOn(MainScheduler.instance)
                .subscribeNext({ (arr) in
                    self.loadAutos(true)
                }).addDisposableTo(self.disposeBag)
        } 
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.storedFilter = Filter.createCopy(ApplicationState.sharedInstance().filter)
    }
    
    func loadAutos(fromFilter: Bool){
        if(!fromFilter){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                    self.publishSubject.onNext(RealmManager.getAutos())
            })
        } else {
            let autosClient = AutosClient(_token: PreferencesManager.getToken() ?? "")
            autosClient.autosObservableWithFilter()
            .observeOn(MainScheduler.instance)
            .subscribeNext({ (arr) in
                self.publishSubject.onNext(arr)
            }).addDisposableTo(self.disposeBag)
        }
    }
    
    func addBindsToViewModel(){
        self.publishSubject
        .observeOn(MainScheduler.instance)
        .bindTo(collection.rx_itemsWithCellFactory) { [unowned self](collectionView, row, element) in
            let indexPath = NSIndexPath(forItem: row, inSection: 0)
            let cell = self.collection.dequeueReusableCellWithReuseIdentifier(self.CELL_IDENTIFIER, forIndexPath: indexPath) as! AutoCollectionCell
            cell.registrationNumber.text = element.registrationNumber ?? ""
            cell.companyName.text = element.organization ?? ""
            cell.model.text = element.model ?? ""
            cell.modelName.text = element.type ?? ""
            
            cell.contentView.layer.cornerRadius = 8.0
            cell.contentView.clipsToBounds = true
            cell.registrationNumber.layer.cornerRadius = 4.0
            cell.registrationNumber.clipsToBounds = true
            
            
            if let lastUpdate = element.lastUpdate{
                let date = NSDate(timeIntervalSince1970: Double(lastUpdate))
                let dateFormatter = NSDateFormatter()
                dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
                cell.lastUpdate.text = dateFormatter.stringFromDate(date)
            } else {
                cell.lastUpdate.text = ""
            }
            
            return cell
        }.addDisposableTo(self.disposeBag)
        
    }
    
    
    func addCollectionBinds(){
        self.collection.rx_modelSelected(Auto)
            .observeOn(MainScheduler.instance)
            .subscribeNext { [unowned self](auto) in
                if let autoId = auto.id{
                    self.performSegueWithIdentifier(self.AUTO_DETAIL_SEGUE, sender: NSNumber(long: autoId))
                }
        }.addDisposableTo(self.disposeBag)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == AUTO_DETAIL_SEGUE){
            if let destVC = segue.destinationViewController as? AutoViewController{
                if let autoId = sender as? NSNumber{
                    destVC.autoId = autoId.longLongValue
                }
            }
        }
    }
    
    //MARK: IBActions
    @IBAction func menuPressed(sender: AnyObject) {
        ApplicationState.sharedInstance().showLeftPanel()
    }
    
   
    @IBAction func filter(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(FILTER_STORYBOARD_ID)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
