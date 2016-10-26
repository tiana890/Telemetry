
/*******************************************************************************************/
import UIKit
import RxSwift
import SwiftyJSON
import GoogleMaps
import CoreGraphics
import QuartzCore
import PKHUD

class MapVehiclesViewController: UIViewController, GMUClusterManagerDelegate, GMSMapViewDelegate{
    
    let FILTER_STORYBOARD_ID = "FilterStoryboardID"
    let kClusterItemCount = 10000
    
    
    var mapView: GMSMapView?
    @IBOutlet weak var filterView: UIView!
    
    fileprivate var clusterManager: GMUClusterManager!
    
    var dict = [Int64: (vehicle: Vehicle, spot: POIItem)]()
    
    var viewModel :VehiclesViewModel?
    var token: String?

    var algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    
    var disposeBag = DisposeBag()
    var socketBag: DisposeBag?

    var telemetryClient: TelemetryClient?
    var storedFilter = Filter.createCopy(ApplicationState.sharedInstance.filter)
    
    var isAutosLoaded: Bool{
        get{
            return PreferencesManager.ifAutosLoaded()
        }
    }
    
    var isFilterSet: Bool{
        get{
            return ApplicationState.sharedInstance.filter?.filterIsSet() ?? false
        }
    }
    
    //MARK: IBOutlets
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet var updateBtn: UIBarButtonItem!

    //MARK: UIViewController methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMap()
        initRenderer()
        
        print(ApplicationState.sharedInstance.getToken())
        
        if(!isAutosLoaded){
            HUD.show(.labeledProgress(title: "Загрузка справочника ТС", subtitle: "Это может занять некоторое время"))
            updateAutos()
        } else {
            updateMap()
        }
        
        self.updateBtn.action = #selector(updateBtnPressed)

    }
    
    @IBAction func updateBtnPressed(_ sender: AnyObject) {
        self.updateMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        clearAllTraysFromMap()
        
        
        
        if let f = self.storedFilter{
            
            if(!f.isEqualToFilter(ApplicationState.sharedInstance.filter)){

                self.clearMap()
                if(isFilterSet){
                    HUD.show(.labeledProgress(title: "Поиск по фильтру", subtitle: ""))
                    let autosClient = AutosClient(_token: PreferencesManager.getToken() ?? "")
                    autosClient.autosIDsObservableWithFilter()
                        .observeOn(MainScheduler.instance)
                        .do(onError: { [unowned self](errType) in
                            HUD.flash(.labeledError(title: "Ошибка", subtitle: "Невозможно получить данные"), delay: 2, completion: nil)
                            self.updateMap([])
                        })
                        .subscribe(onNext: { [unowned self](arr) in
                            
                            if(arr.count > 0){
                                self.showFilterView()
                                HUD.flash(.label("Найдено \(arr.count) объектов"), delay: 2, completion: nil)
                            } else {
                                HUD.flash(.label("Объекты не найдены. Измените параметры фильтра."), delay: 2, completion: nil)
                            }
                            
                            self.updateMap(arr)
                        }).addDisposableTo(self.disposeBag)
                } else {
                    self.updateMap()
                }
                
                
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.storedFilter = Filter.createCopy(ApplicationState.sharedInstance.filter)
    }
    
    func showFilterView(){
        self.filterView.isHidden = false
        self.view.bringSubview(toFront: self.filterView)
        self.view.layoutSubviews()
        
    }
    
    func hideFilterView(){
        self.filterView.isHidden = true
    }
    
    //MARK: Init functions
    
    func initMap(){
        self.mapView = GMSMapView(frame: self.view.frame)
        mapView!.delegate = self
        self.view.addSubview(mapView!)
    }
    
    func initRenderer(){
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView!, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView!, algorithm: algorithm, renderer: renderer)
        self.mapView!.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude:  55.75222, longitude: 37.61556), zoom: 10, bearing: 0, viewingAngle: 0)
        
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    //MARK: Logic functions
    
    func updateAutos(){
        self.indicator.isHidden = true
        AutosClient(_token: ApplicationState.sharedInstance.getToken() ?? "")
            .autosDictJSONObservable()
            .observeOn(MainScheduler.instance)
            .do(onError: { (errType) in
                HUD.flash(.labeledError(title: "Ошибка", subtitle: "Не удалось загрузить справочник ТС. Информация о ТС может отображаться некорректно."), delay: 2, completion: nil)
                PreferencesManager.setAutosLoaded(false)
                self.indicator.isHidden = false
                self.updateMap()
            })
            .subscribe({ (event) in
                if(!event.isStopEvent){
                    HUD.flash(.success)
                    PreferencesManager.setAutosLoaded(true)
                    self.indicator.isHidden = false
                    self.updateMap()
                }
            })
            .addDisposableTo(self.disposeBag)
    }
    
    //MARK: Map functions
    
    func updateMap(){
        
        self.addBindsToViewModel([])
    }
    
    func updateMap(_ arr: [Int]){
        self.hideFilterView()
        if(arr.count == 0){
            self.updateBtn.isEnabled = true
            self.updateBtn.image = UIImage(named: "update_icon")
            
        } else {
            self.addBindsToViewModel(arr)
        }
    }
    
    func clearMap(){
        telemetryClient?.closeSocket()
        self.disposeBag = DisposeBag()
        self.socketBag = DisposeBag()
        clearAllTraysFromMap()
        self.clusterManager.clearItems()
        self.dict.removeAll()
    }
    
    func addBindsToViewModel(_ vehicles:[Int]){

        self.clearAllTraysFromMap()
        
        self.mapView?.clear()
        self.mapView!.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude:  55.75222, longitude: 37.61556), zoom: 10, bearing: 0, viewingAngle: 0)
        
        self.socketBag = nil
        self.socketBag = DisposeBag()
        
        self.telemetryClient = TelemetryClient(token: ApplicationState.sharedInstance.getToken() ?? "", bounds: self.mapView!.getBounds())
        self.telemetryClient?.setVehicles(vehicles)
        
        self.viewModel = VehiclesViewModel(telemetryClient: self.telemetryClient!)
        
        self.indicator.isHidden = false
        self.indicator.startAnimating()
        
        self.updateBtn.isEnabled = false
        self.updateBtn.image = nil
        
        self.viewModel?
        .vehicles
        .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        .subscribe(onNext: { [unowned self](vehicles) in
            
            self.appendMarkersOnMap(vehicles.array)
            DispatchQueue.main.async(execute: { 
                self.clusterManager.cluster()
                self.indicator.isHidden = true
                self.updateBtn.isEnabled = true
            })
            
        }, onError: { [unowned self](errType) in
            
            DispatchQueue.main.async(execute: {
                self.indicator.isHidden = true
                self.updateBtn.image = UIImage(named: "update_icon")
                self.updateBtn.isEnabled = true
                
                if let error = errType as? APIError{
                    self.showAlert("", msg: error.getReason())
                } else {
                    self.showAlert("", msg: "Произошла ошибка")
                }
    
            })
            
        }, onCompleted: { [unowned self] in
            self.indicator.isHidden = true
            self.updateBtn.image = UIImage(named: "update_icon")
            self.updateBtn.isEnabled = true
        }, onDisposed: {
                
        }).addDisposableTo(self.disposeBag)
    }

    func appendMarkersOnMap(_ array: [Vehicle]){

        //Find current markers in dict
        for(veh) in array{
            guard veh.id != nil else { break }
            guard veh.lat != nil else { break }
            guard veh.lon != nil else { break }
            guard veh.azimut != nil else { break }
            
            if let value = dict[veh.id!]{
                if(value.vehicle.lat! == veh.lat && value.vehicle.lon! == veh.lon && value.vehicle.azimut! == veh.azimut){
                    
                } else {
                    DispatchQueue.main.async(execute: {
                        self.clusterManager.remove(value.spot)
                    })
                    
                    let spot = addMarkerAndCreateSpot(veh)
                    spot.prevLon = String(value.spot.position.longitude)
                    spot.prevLat = String(value.spot.position.latitude)
                    spot.hasAnimated = false
                    if(value.spot.selected == true){
                        spot.selected = value.spot.selected
                    }
                    dict[veh.id!] = (vehicle: veh, spot: spot)
                    DispatchQueue.main.async(execute: {
                        self.clusterManager.add(spot)
                    })
                }
                
            } else {
                let spot = addMarkerAndCreateSpot(veh)
                spot.prevLat = nil
                spot.prevLon = nil
                spot.hasAnimated = true
                dict[veh.id!] = (vehicle: veh, spot: spot)
                DispatchQueue.main.async(execute: {
                    self.clusterManager.add(spot)
                })
            }
        }
    }
    
    func addMarkerAndCreateSpot(_ vehicle: Vehicle) -> POIItem{
        
        let pos = CLLocationCoordinate2D(latitude: vehicle.lat!, longitude: vehicle.lon!)
        let spot = POIItem()
        spot.vehicleId = NSNumber(value: vehicle.id! as Int64)
        spot.position = pos
        if let auto = RealmManager.getAutoById(Int(vehicle.id!)){
            spot.regNumber = !PreferencesManager.showGarageNumber() ? (auto.registrationNumber ?? "") : (auto.garageNumber ?? "")
        }
        if let azm = vehicle.azimut{
            spot.azimut = NSNumber(value: azm as Double)
        }
        spot.name = "\(vehicle.id)"
        spot.hasAnimated = false
        return spot
        
    }
    
    func clearAllTraysFromMap(){
        for (spot) in Array(self.dict.values){
            if(spot.spot.polylines != nil){
                for (line) in spot.spot.polylines{
                    (line as! GMSPolyline).map = nil
                }
                spot.spot.polylines.removeAllObjects()
            }
        }
    }
    
    //MARK: IBActions
    @IBAction func filter(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: FILTER_STORYBOARD_ID)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func menuPressed(_ sender: AnyObject) {
        ApplicationState.sharedInstance.showLeftPanel()
    }
    
    //MARK: GMSMapViewDelegate
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let item = marker.userData as? POIItem else {
            mapView.selectedMarker = nil
            for(val) in self.dict.values{
                val.spot.selected = false
            }
            return nil
        }

        for(val) in self.dict.values{
            val.spot.selected = false
        }
        item.selected = true
        
        let vehicleId = Int(item.vehicleId.int32Value)
        guard let auto = RealmManager.getAutoById(vehicleId) else {
            return Bundle.main.loadNibNamed("MarkerWindow", owner: self, options: nil)?[0] as? MarkerWindow
        }
        
        if let markerView = Bundle.main.loadNibNamed("MarkerWindow", owner: self, options: nil)?[0] as? MarkerWindow{
            markerView.company.text = auto.organization ?? ""
            markerView.regNumber.text = !PreferencesManager.showGarageNumber() ? (auto.registrationNumber ?? "") : (auto.garageNumber ?? "")
            markerView.model.text = auto.model ?? ""
            markerView.modelName.text = auto.type ?? ""
            markerView.layer.cornerRadius = 4.0
            markerView.clipsToBounds = true
            markerView.regNumber.layer.cornerRadius = 4.0
            markerView.regNumber.clipsToBounds = true

            if let lastUpdate = auto.lastUpdate{
                let date = Date(timeIntervalSince1970: Double(lastUpdate))
                let dateFormatter = DateFormatter()
                dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
            }
            
            return markerView
        }
        return nil
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        mapView.selectedMarker = nil
        for(val) in self.dict.values{
            val.spot.selected = false
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.selectedMarker = nil
        for(val) in self.dict.values{
            val.spot.selected = false
        }
    }

    //MARK: -Alerts
    func showAlert(_ title: String, msg: String){
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    deinit{
        print("DEINIT")
    }
}


