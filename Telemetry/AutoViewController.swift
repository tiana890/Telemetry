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
    let FOLLOW_VEHICLE_SEGUE_IDENTIFIER = "followMapSegue"
    
    var autoId: Int64?
    var garageNumber: String?
    var viewModel :AutoViewModel?
    var autoClient: AutoClient?
    
    let disposeBag = DisposeBag()
    var items = Observable<[(cellID:String, name: String)]>.empty()
    
    weak var autosViewController: AutosViewController?
    
    //MARK: IBOutlets
    @IBOutlet var table: UITableView!
    @IBOutlet var companyName: UILabel!

    var showTrackIndex = -1
    var followVehicleIndex = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        autoClient = AutoClient(_token: ApplicationState.sharedInstance.getToken() ?? "", _autoId: autoId ?? 0)
        self.viewModel = AutoViewModel(autoClient: autoClient!)
        
        addBindsToViewModel()
        addTableBinds()
    }
    
    func addBindsToViewModel(){
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        indicator.startAnimating()
        self.view.addSubview(indicator)
        self.table.isHidden = true
        
        self.viewModel?.auto
            .observeOn(MainScheduler.instance)
            .do(onError: { (errType) in
                self.table.isHidden = false
                indicator.removeFromSuperview()
                self.showAlert("Ошибка", msg: "Невозможно загрузить данные")
            })
            .flatMap({ [unowned self](auto) -> Observable<[(cellID:String, name: String)]> in
                indicator.removeFromSuperview()
                self.table.isHidden = false
                return Observable.just(self.createItemsArrayFromAutoModel(auto))
            })
            .bindTo(table.rx.items){ [unowned self](tableView, row, element) in
                let indexPath = IndexPath(item: row, section: 0)
                let cell = self.table.dequeueReusableCell(withIdentifier: element.cellID, for: indexPath) as! CommonCell
                cell.mainText.text = element.name
                return cell
            }.addDisposableTo(self.disposeBag)
        
    }
    
    func addTableBinds(){
        self.table
        .rx
        .itemSelected
        .subscribe { (event) in
            guard let ip = event.element else { return }
            if(ip.row == self.showTrackIndex){
                self.performSegue(withIdentifier: self.SHOW_TRACK_SEGUE_IDENTIFIER, sender: nil)
            }else if(ip.row == self.followVehicleIndex){
                self.performSegue(withIdentifier: self.FOLLOW_VEHICLE_SEGUE_IDENTIFIER, sender: nil)
            }
        }.addDisposableTo(self.disposeBag)
    }
    
    func createItemsArrayFromAutoModel(_ auto: AutoDetail) -> [(cellID:String, name: String)]{
        var array = [(cellID:String, name: String)]()
        
        array.append((self.HEADER_CELL_IDENTIFIER, "Модель ТС"))
        array.append((self.COMMON_CELL_IDENTIFIER, auto.model ?? ""))
        array.append((self.HEADER_CELL_IDENTIFIER, "Тип"))
        array.append((self.COMMON_CELL_IDENTIFIER, auto.type ?? ""))
        array.append((self.HEADER_CELL_IDENTIFIER, "Регистрационный номер"))
        array.append((self.COMMON_CELL_IDENTIFIER, auto.registrationNumber ?? ""))
        
        if(self.garageNumber != nil){
            array.append((self.HEADER_CELL_IDENTIFIER, " Гаражный номер"))
            array.append((self.COMMON_CELL_IDENTIFIER, self.garageNumber ?? ""))
        }
        
        array.append((self.HEADER_CELL_IDENTIFIER, "Организация"))
        array.append((self.COMMON_CELL_IDENTIFIER, auto.organization ?? ""))
        
        if let speed = auto.speed{
            array.append((self.HEADER_CELL_IDENTIFIER, "Скорость"))
            array.append((self.COMMON_CELL_IDENTIFIER, "\(speed)" ))
        }
        if let glonasId = auto.glonasId{
            if(glonasId > 0){
                array.append((self.HEADER_CELL_IDENTIFIER, "Глонасс ID"))
                array.append((self.COMMON_CELL_IDENTIFIER, "\(glonasId)"))
            }
        }
        
        if let lastUpdate = auto.lastUpdate{
            let date = Date(timeIntervalSince1970: Double(lastUpdate))
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
            array.append((self.HEADER_CELL_IDENTIFIER, "Дата последнего обновления"))
            array.append((self.COMMON_CELL_IDENTIFIER, dateFormatter.string(from: date)))
        }
        
        if let sensors = auto.sensors{
            if(sensors.count > 0){
                array.append((self.HEADER_CELL_IDENTIFIER, "Датчики"))
            }
            for sensor in sensors{
                array.append((self.COMMON_CELL_IDENTIFIER, sensor.name ?? ""))
            }
        }
        
        array.append((self.HEADER_CELL_IDENTIFIER, "Проиграть трек"))
        array.append((self.COMMON_ARROW_CELL_IDENTIFIER, "Выбрать параметры трека"))
        self.showTrackIndex = array.count - 1
        array.append((self.HEADER_CELL_IDENTIFIER, "Следить за ТС"))
        array.append((self.COMMON_ARROW_CELL_IDENTIFIER, "Следить за ТС"))
        self.followVehicleIndex = array.count - 1
        
        return array
    }
    
    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.autosViewController?.shouldUpdate = false
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == SHOW_TRACK_SEGUE_IDENTIFIER){
            if let destVC = segue.destination as? TrackParamsViewController{
                destVC.autoId = self.autoId
            }
        } else if(segue.identifier == FOLLOW_VEHICLE_SEGUE_IDENTIFIER){
            if let destVC = segue.destination as? FollowVehicleViewController{
                destVC.autoId = self.autoId
            }
        }
        
    }
    
    func showAlert(_ title: String, msg: String){
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
