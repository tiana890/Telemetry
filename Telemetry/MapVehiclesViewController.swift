
/*******************************************************************************************/
import UIKit
import RxSwift
import SwiftyJSON
import GoogleMaps
import CoreGraphics
import QuartzCore

class MapVehiclesViewController: UIViewController, GMUClusterManagerDelegate, GMSMapViewDelegate{
    
    let FILTER_STORYBOARD_ID = "FilterStoryboardID"

    let kClusterItemCount = 10000
    
    var mapView: GMSMapView?
    
    private var clusterManager: GMUClusterManager!
    
    var dict = [Int64: (vehicle: Vehicle, spot: POIItem)]()
    
    var viewModel :VehiclesViewModel?
    var token: String?

    var algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    
    var disposeBag = DisposeBag()
    var socketBag: DisposeBag?

    var telemetryClient: TelemetryClient?
    var storedFilter = Filter.createCopy(ApplicationState.sharedInstance().filter)
    
    
    //MARK: IBOutlets
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet var updateBtn: UIBarButtonItem!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMap()
        
        print(ApplicationState.sharedInstance().getToken())

        let iconGenerator = GMUDefaultClusterIconGenerator()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView!, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView!, algorithm: algorithm, renderer: renderer)
        self.mapView!.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude:  55.75222, longitude: 37.61556), zoom: 10, bearing: 0, viewingAngle: 0)

        clusterManager.setDelegate(self, mapDelegate: self)
        
        if(!PreferencesManager.ifAutosLoaded()){
            self.updateBtn.enabled = false
            
            let progressHUD = ProgressHUD(text: "Загрузка справочника ТС. Подождите некоторое время.")
            progressHUD.tag = 1234
            progressHUD.frame.size = CGSize(width: 280.0, height: 50.0)
            progressHUD.center = self.view.center
            self.view.addSubview(progressHUD)
            
            self.view.userInteractionEnabled = false
            
            AutosClient(_token: ApplicationState.sharedInstance().getToken() ?? "")
                .autosDictJSONObservable()
                .observeOn(MainScheduler.instance)
                .doOnError({ (errType) in
                    progressHUD.removeFromSuperview()
                    self.showAlert("Ошибка", msg: "Не удалось загрузить справочник ТС. Информация о ТС может отображаться некорректно.")
                    self.view.userInteractionEnabled = true
                    PreferencesManager.setAutosLoaded(false)
                    self.updateMap()
                })
                .subscribeNext { (autosDictResponse) in
                    progressHUD.removeFromSuperview()
                    self.view.userInteractionEnabled = true
                    PreferencesManager.setAutosLoaded(true)
                    self.updateMap()
                }.addDisposableTo(self.disposeBag)
        } else {
            self.updateMap()
        }
        
        self.updateBtn
            .rx_tap
            .observeOn(MainScheduler.instance)
            .subscribeNext { [unowned self]() in
                self.updateMap()
            }.addDisposableTo(self.disposeBag)
        }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
       
        if let f = self.storedFilter{
            print(f)
            print(ApplicationState.sharedInstance().filter)
            if(!f.isEqualToFilter(ApplicationState.sharedInstance().filter)){
                self.clearMap()
                let autosClient = AutosClient(_token: PreferencesManager.getToken() ?? "")
                autosClient.autosIDsObservableWithFilter()
                .observeOn(MainScheduler.instance)
                .subscribeNext({ (arr) in
                    self.updateMap(arr)
                }).addDisposableTo(self.disposeBag)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.storedFilter = Filter.createCopy(ApplicationState.sharedInstance().filter)
    }
    
    func initMap(){
        mapView = GMSMapView(frame: self.view.frame)
        mapView!.delegate = self
        self.view.addSubview(mapView!)
    }
    
    func updateMap(){
        
        self.addBindsToViewModel([])
    }
    
    func updateMap(arr: [Int]){
        if(arr.count == 0){
            self.showAlert("Внимание", msg: "Нет результатов, соответствующих фильтру")
            
            self.updateBtn.enabled = true
            self.updateBtn.image = UIImage(named: "update_icon")
            
        } else {
            self.addBindsToViewModel(arr)
        }
    }
    
    func clearMap(){
        telemetryClient?.closeSocket()
        self.socketBag = DisposeBag()
        clearAllTraysFromMap()
        self.clusterManager.clearItems()
        self.dict.removeAll()
    }
    
    func addBindsToViewModel(vehicles:[Int]){

        self.clearAllTraysFromMap()
        self.mapView!.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude:  55.75222, longitude: 37.61556), zoom: 10, bearing: 0, viewingAngle: 0)
        
        self.socketBag = nil
        self.socketBag = DisposeBag()
        
        self.telemetryClient = TelemetryClient(token: ApplicationState.sharedInstance().getToken() ?? "", bounds: self.mapView!.getBounds())
        self.telemetryClient?.setVehicles(vehicles)
        
        self.viewModel = VehiclesViewModel(telemetryClient: self.telemetryClient!)
        
        self.indicator.hidden = false
        self.indicator.startAnimating()
        
        self.updateBtn.enabled = false
        self.updateBtn.image = nil
        
        self.viewModel?
        .vehicles
        .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
        .debug()
        .subscribe(onNext: { [unowned self](vehicles) in
            
            self.appendMarkersOnMap(vehicles.array)
            dispatch_async(dispatch_get_main_queue(), { 
                self.clusterManager.cluster()
                self.indicator.hidden = true
            })
            
        }, onError: { [unowned self](errType) in
            
            dispatch_async(dispatch_get_main_queue(), {
                self.indicator.hidden = true
                self.updateBtn.image = UIImage(named: "update_icon")
                self.updateBtn.enabled = true
                
                if let error = errType as? APIError{
                    self.showAlert("", msg: error.getReason())
                } else {
                    self.showAlert("", msg: "Произошла ошибка")
                }
    
            })
            
        }, onCompleted: { [unowned self] in
            self.indicator.hidden = true
            self.updateBtn.image = UIImage(named: "update_icon")
            self.updateBtn.enabled = true
        }, onDisposed: {
                
    }).addDisposableTo(self.disposeBag)
    }

    func appendMarkersOnMap(array: [Vehicle]){

        //Find current markers in dict
        for(veh) in array{
            guard veh.id != nil else { break }
            guard veh.lat != nil else { break }
            guard veh.lon != nil else { break }
            guard veh.azimut != nil else { break }
            
            if let value = dict[veh.id!]{
                if(value.vehicle.lat! == veh.lat && value.vehicle.lon! == veh.lon && value.vehicle.azimut! == veh.azimut){
                    
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.clusterManager.removeItem(value.spot)
                    })
                    
                    let spot = addMarkerAndCreateSpot(veh)
                    spot.prevLon = String(value.spot.position.longitude)
                    spot.prevLat = String(value.spot.position.latitude)
                    spot.hasAnimated = false
                    if(value.spot.selected == true){
                        spot.selected = value.spot.selected
                    }
                    dict[veh.id!] = (vehicle: veh, spot: spot)
                    dispatch_async(dispatch_get_main_queue(), {
                        self.clusterManager.addItem(spot)
                    })
                }
                
            } else {
                let spot = addMarkerAndCreateSpot(veh)
                spot.prevLat = nil
                spot.prevLon = nil
                spot.hasAnimated = true
                dict[veh.id!] = (vehicle: veh, spot: spot)
                dispatch_async(dispatch_get_main_queue(), {
                    self.clusterManager.addItem(spot)
                })
            }
        }
    }
    
    func addMarkerAndCreateSpot(vehicle: Vehicle) -> POIItem{
        
        let pos = CLLocationCoordinate2D(latitude: vehicle.lat!, longitude: vehicle.lon!)
        let spot = POIItem()
        spot.vehicleId = NSNumber(longLong: vehicle.id!)
        spot.position = pos
        if let auto = RealmManager.getAutoById(Int(vehicle.id!)){
            spot.regNumber = auto.registrationNumber ?? ""
        }
        if let azm = vehicle.azimut{
            spot.azimut = NSNumber(double: azm)
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
    @IBAction func filter(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(FILTER_STORYBOARD_ID)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func menuPressed(sender: AnyObject) {
        ApplicationState.sharedInstance().showLeftPanel()
    }
    
    //MARK: GMSMapViewDelegate
    func mapView(mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
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
        
        let vehicleId = Int(item.vehicleId.intValue)
        guard let auto = RealmManager.getAutoById(vehicleId) else {
            return NSBundle.mainBundle().loadNibNamed("MarkerWindow", owner: self, options: nil)[0] as? MarkerWindow
        }
        
        if let markerView = NSBundle.mainBundle().loadNibNamed("MarkerWindow", owner: self, options: nil)[0] as? MarkerWindow{
            markerView.company.text = auto.organization ?? ""
            markerView.regNumber.text = auto.registrationNumber ?? ""
            markerView.model.text = auto.model ?? ""
            markerView.modelName.text = auto.type ?? ""
            markerView.layer.cornerRadius = 4.0
            markerView.clipsToBounds = true
            markerView.regNumber.layer.cornerRadius = 4.0
            markerView.regNumber.clipsToBounds = true

            if let lastUpdate = auto.lastUpdate{
                let date = NSDate(timeIntervalSince1970: Double(lastUpdate))
                let dateFormatter = NSDateFormatter()
                dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
            }
            
            return markerView
        }
        return nil
    }
    
    func mapView(mapView: GMSMapView, didTapOverlay overlay: GMSOverlay) {
        mapView.selectedMarker = nil
        for(val) in self.dict.values{
            val.spot.selected = false
        }
    }
    
    func mapView(mapView: GMSMapView, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        mapView.selectedMarker = nil
        for(val) in self.dict.values{
            val.spot.selected = false
        }
    }

    //MARK: -Alerts
    func showAlert(title: String, msg: String){
        let alert = UIAlertController(title: title,
                                      message: msg,
                                      preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .Cancel, handler: nil)
        
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    deinit{
        print("DEINIT")
    }
}
   