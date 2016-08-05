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
    
    let FILTER_STORYBOARD_ID = "FilterStoryboardID"
    
    let AUTO_DETAIL_SEGUE = "autoDetailSegue"
    let CELL_IDENTIFIER = "autoCollectionCell"
    
    var viewModel:AutosViewModel?
    var autosClient:AutosClient?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        autosClient = AutosClient(_token: ApplicationState.sharedInstance().getToken() ?? "")
        self.viewModel = AutosViewModel(autosClient: autosClient!)
        
        addBindsToViewModel()
        addCollectionBinds()
    }
    
    func addBindsToViewModel(){
        
        self.viewModel?.autos
            .observeOn(MainScheduler.instance)
            .bindTo(collection.rx_itemsWithCellFactory) { [unowned self](collectionView, row, element) in
                let indexPath = NSIndexPath(forItem: row, inSection: 0)
                let cell = self.collection.dequeueReusableCellWithReuseIdentifier(self.CELL_IDENTIFIER, forIndexPath: indexPath) as! AutoCollectionCell
                cell.registrationNumber.text = element.registrationNumber ?? ""
                cell.companyName.text = element.organization ?? ""
                cell.modelName.text = element.modelName ?? ""
                cell.model.text = element.model ?? ""
                cell.group.text = element.group ?? ""
                
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
                    self.performSegueWithIdentifier(self.AUTO_DETAIL_SEGUE, sender: NSNumber(longLong: autoId))
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
