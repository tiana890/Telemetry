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
import PKHUD

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
    
    var storedFilter = Filter.createCopy(ApplicationState.sharedInstance.filter)
    var shouldUpdate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collection.delegate = self
        
        addCollectionBinds()
        addBindsToViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard shouldUpdate == true else {
            shouldUpdate = true
            return
        }
        
        guard let f = self.storedFilter else {
            self.loadAutos(false)
            return
        }
        
        if(!f.isEqualToFilter(ApplicationState.sharedInstance.filter)){
            if(ApplicationState.sharedInstance.filter?.filterIsSet() ?? false){
                self.loadAutos(true)
            } else {
                self.loadAutos(false)
            }
        } else {
            self.loadAutos(false)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.storedFilter = Filter.createCopy(ApplicationState.sharedInstance.filter)
    }
    
    func loadAutos(_ fromFilter: Bool){
        self.filterView.isHidden = true
        self.publishSubject.onNext([])
        
        if(!fromFilter){
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicator.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
            indicator.startAnimating()
            self.view.addSubview(indicator)
            
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async(execute: {
                    let autos = RealmManager.getAutos()
                    DispatchQueue.main.async(execute: {
                        indicator.removeFromSuperview()
                    })
                    self.publishSubject.onNext(autos)
            })
        } else {
            HUD.show(.labeledProgress(title: "Поиск по фильтру", subtitle: ""))
            let autosClient = AutosClient(_token: PreferencesManager.getToken() ?? "")
            
            autosClient.autosObservableWithFilter()
            .observeOn(MainScheduler.instance)
            .do(onError: { (err) in
                HUD.flash(.labeledError(title: "Ошибка", subtitle: "Невозможно получить данные"), delay: 2, completion: nil)
            })
            .subscribe({ (event) in
                guard let arr = event.element else { return }
                if(arr.count > 0){
                    self.filterView.isHidden = false
                    HUD.flash(.label("Найдено \(arr.count) объектов"), delay: 2, completion: nil)
                } else {
                    HUD.flash(.label("Объекты не найдены."), delay: 2, completion: nil)
                }
                self.publishSubject.onNext(arr)
            })
            .addDisposableTo(self.disposeBag)
        }
    }
    
    func addBindsToViewModel(){
        
        
        self.publishSubject
        .observeOn(MainScheduler.instance)
        .bindTo(collection.rx.items(cellIdentifier: self.CELL_IDENTIFIER)) { (collectionView, element, c) in
            
            let cell = c as! AutoCollectionCell
            cell.registrationNumber.text = element.registrationNumber ?? ""
            cell.companyName.text = element.organization ?? ""
            cell.model.text = element.model ?? ""
            cell.modelName.text = element.type ?? ""
            
            cell.contentView.layer.cornerRadius = 8.0
            cell.contentView.clipsToBounds = true
            cell.registrationNumber.layer.cornerRadius = 4.0
            cell.registrationNumber.clipsToBounds = true
            cell.garageNumber.text = element.garageNumber ?? ""
            
            if let lastUpdate = element.lastUpdate{
                let date = Date(timeIntervalSince1970: Double(lastUpdate))
                let dateFormatter = DateFormatter()
                dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
                cell.lastUpdate.text = dateFormatter.string(from: date)
            } else {
                cell.lastUpdate.text = ""
            }
            
        }.addDisposableTo(self.disposeBag)
        
    }
    
    
    func addCollectionBinds(){
        self.collection.rx.modelSelected(Auto.self)
            .observeOn(MainScheduler.instance)
            .subscribe({ [unowned self](event) in
                guard let auto = event.element else { return }
                if let autoId = auto.id{
                    self.performSegue(withIdentifier: self.AUTO_DETAIL_SEGUE, sender: auto)
                }
        }).addDisposableTo(self.disposeBag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == AUTO_DETAIL_SEGUE){
            if let destVC = segue.destination as? AutoViewController{
                if let auto = sender as? Auto{
                    destVC.auto = auto
                    destVC.autosViewController = self
                    destVC.autoId = Int64(auto.id ?? 0)
                }
            }
        }
    }
    
    //MARK: IBActions
    @IBAction func menuPressed(_ sender: AnyObject) {
        ApplicationState.sharedInstance.showLeftPanel()
    }
    
   
    @IBAction func filter(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: FILTER_STORYBOARD_ID)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension AutosViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = UIScreen.main.bounds.width
        if(screenWidth <= 414.0){
            return CGSize(width: screenWidth - 12.0, height: 148.0)
        } else {
            if(screenWidth > 314.0*2 && screenWidth < 314.0*3){
                return CGSize(width: 350.0, height: 148.0)
            }
            return CGSize(width: 314.0, height: 148.0)
        }
    }

}
