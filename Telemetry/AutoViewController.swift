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
    
    let HEADER_CELL_IDENTIFIER = "headerCell"
    let COMMON_CELL_IDENTIFIER = "commonCell"
    let COMMON_ARROW_CELL_IDENTIFIER = "commonArrowCell"
    
    
    let SHOW_TRACK_SEGUE_IDENTIFIER = "showTrack"
    let FOLLOW_VEHICLE_SEGUE_IDENTIFIER = "followVehicle"
    
    var autoId: Int64?
    var viewModel :AutoViewModel?
    var autoClient: AutoClient?
    
    let disposeBag = DisposeBag()
    var items = Observable<[(cellID:String, name: String)]>.empty()
    
    weak var autosViewController: AutosViewController?
    
    //MARK: IBOutlets
    @IBOutlet var table: UITableView!
    @IBOutlet var companyName: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoClient = AutoClient(_token: ApplicationState.sharedInstance().getToken() ?? "", _autoId: autoId ?? 0)
        self.viewModel = AutoViewModel(autoClient: autoClient!)
        
        addBindsToViewModel()

    }
    
    func addBindsToViewModel(){
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        indicator.center = CGPoint(x: UIScreen.mainScreen().bounds.width/2, y: UIScreen.mainScreen().bounds.height/2)
        indicator.startAnimating()
        self.view.addSubview(indicator)
        
        self.viewModel?.auto
            .observeOn(MainScheduler.instance)
            .doOnError({ (errType) in
                indicator.removeFromSuperview()
            })
            .flatMap({ [unowned self](auto) -> Observable<[(cellID:String, name: String)]> in
                indicator.removeFromSuperview()
                return Observable.just(self.createItemsArrayFromAutoModel(auto))
            })
            .bindTo(table.rx_itemsWithCellFactory){ [unowned self](tableView, row, element) in
                let indexPath = NSIndexPath(forItem: row, inSection: 0)
                let cell = self.table.dequeueReusableCellWithIdentifier(element.cellID, forIndexPath: indexPath) as! CommonCell
                cell.mainText.text = element.name
                
                return cell
            }.addDisposableTo(self.disposeBag)
        
    }
    
    func addTableBinds(){
        
    }
    
    func createItemsArrayFromAutoModel(auto: AutoDetail) -> [(cellID:String, name: String)]{
        var array = [(cellID:String, name: String)]()
        
        array.append((self.HEADER_CELL_IDENTIFIER, "Модель ТС"))
        array.append((self.COMMON_CELL_IDENTIFIER, auto.model ?? ""))
        array.append((self.HEADER_CELL_IDENTIFIER, "Тип"))
        array.append((self.COMMON_CELL_IDENTIFIER, auto.type ?? ""))
        array.append((self.HEADER_CELL_IDENTIFIER, "Регистрационный номер"))
        array.append((self.COMMON_CELL_IDENTIFIER, auto.registrationNumber ?? ""))
        array.append((self.HEADER_CELL_IDENTIFIER, "Организация"))
        array.append((self.COMMON_CELL_IDENTIFIER, auto.organization ?? ""))
        
        if let speed = auto.speed{
            array.append((self.HEADER_CELL_IDENTIFIER, "Скорость"))
            array.append((self.COMMON_CELL_IDENTIFIER, "\(speed)" ))
        }
        if let glonasId = auto.glonasId{
            array.append((self.HEADER_CELL_IDENTIFIER, "Глонасс ID"))
            array.append((self.COMMON_CELL_IDENTIFIER, "\(glonasId)"))
        }
        
        if let lastUpdate = auto.lastUpdate{
            let date = NSDate(timeIntervalSince1970: Double(lastUpdate))
            let dateFormatter = NSDateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
            array.append((self.HEADER_CELL_IDENTIFIER, "Дата последнего обновления"))
            array.append((self.COMMON_CELL_IDENTIFIER, dateFormatter.stringFromDate(date)))
        }
        
        array.append((self.HEADER_CELL_IDENTIFIER, "Датчики"))
        
        if let sensors = auto.sensors{
            for sensor in sensors{
                array.append((self.COMMON_CELL_IDENTIFIER, sensor.name ?? ""))
            }
        }
        
        array.append((self.HEADER_CELL_IDENTIFIER, "Проиграть трек"))
        array.append((self.COMMON_ARROW_CELL_IDENTIFIER, "Выбрать параметры трека"))
        array.append((self.HEADER_CELL_IDENTIFIER, "Следить за ТС"))
        array.append((self.COMMON_ARROW_CELL_IDENTIFIER, "Следить за ТС"))
        
        return array
    }
    
    @IBAction func backBtnPressed(sender: AnyObject) {
        self.autosViewController?.shouldUpdate = false
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK: Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == SHOW_TRACK_SEGUE_IDENTIFIER){
            if let destVC = segue.destinationViewController as? TrackParamsViewController{
                destVC.autoId = self.autoId
            }
        }
        
    }
}
