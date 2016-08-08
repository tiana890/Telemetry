
/*******************************************************************************************/
import UIKit
import RxSwift
import SwiftyJSON
import GoogleMaps

class MapVehiclesViewController: BaseViewController, GMUClusterManagerDelegate, GMSMapViewDelegate{
    
    let FILTER_STORYBOARD_ID = "FilterStoryboardID"

    let kClusterItemCount = 10000
    
    var mapView: GMSMapView?
    
    private var clusterManager: GMUClusterManager!
    
    var dict = [Int64: (vehicle: Vehicle, spot: POIItem)]()
    
    var viewModel :VehiclesViewModel?
    var token: String?

    var algorithm = GMUGridBasedClusterAlgorithm()
    
    let mapQueue = dispatch_queue_create("com.Telemetry.backgroundQueue", nil)
    let dispBag = DisposeBag()
    
    var autosDict: [Int64: Auto]?{
        return ApplicationState.sharedInstance().autosDict
    }
    //MARK: IBOutlets
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBAction func menuPressed(sender: AnyObject) {
        ApplicationState.sharedInstance().showLeftPanel()
    }
    
    override func viewDidLoad() {
        
        mapView = GMSMapView(frame: self.view.frame)
        mapView!.delegate = self
        self.view.addSubview(mapView!)
        
        self.indicator.startAnimating()
        viewModel = VehiclesViewModel(telemetryClient: TelemetryClient(token: ApplicationState.sharedInstance().getToken() ?? ""))
        
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView!, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView!, algorithm: algorithm, renderer: renderer)
        self.mapView!.delegate = self
        self.mapView!.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude:  55.75222, longitude: 37.61556), zoom: 10, bearing: 0, viewingAngle: 0)
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
        
        AutosClient(_token: ApplicationState.sharedInstance().getToken() ?? "").autosDictObservable()
        .observeOn(ConcurrentDispatchQueueScheduler(queue: mapQueue))
        .subscribeNext { (autosDictResponse) in
            ApplicationState.sharedInstance().autosDict = autosDictResponse.autosDict
            print(autosDictResponse.autosDict)
        }.addDisposableTo(self.dispBag)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addBindsToViewModel()
    }
    
    func addBindsToViewModel(){

//        let sub = viewModel?.vehiclesMetaInfo.observeOn(MainScheduler.instance).subscribeNext({ [unowned self](mapInfoArr) in
//
//            dispatch_barrier_async(dispatch_get_main_queue(), {
//                self.appendMarkersOnMap(mapInfoArr)
//                self.clusterManager.cluster()
//            })
//            
//        })
        let sub = viewModel?.vehicles.observeOn(MainScheduler.instance).subscribeNext({ [unowned self](vehicles) in
            self.appendMarkersOnMap(vehicles.array)
            self.clusterManager.cluster()
            self.indicator.hidden = true
        })
        addSubscription(sub!)
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
                    self.clusterManager.removeItem(value.spot)
                    
                    let spot = addMarkerAndCreateSpot(veh)
                    spot.prevLon = String(value.spot.position.longitude)
                    spot.prevLat = String(value.spot.position.latitude)
                    spot.hasAnimated = false
                    if(value.spot.selected == true){
                        spot.selected = value.spot.selected
                    }
                    dict[veh.id!] = (vehicle: veh, spot: spot)
                    self.clusterManager.addItem(spot)
                }
                
            } else {
                let spot = addMarkerAndCreateSpot(veh)
                spot.prevLat = nil
                spot.prevLon = nil
                spot.hasAnimated = true
                dict[veh.id!] = (vehicle: veh, spot: spot)
                self.clusterManager.addItem(spot)
            }
        }
    }
    
    func addMarkerAndCreateSpot(vehicle: Vehicle) -> POIItem{
        let pos = CLLocationCoordinate2D(latitude: vehicle.lat!, longitude: vehicle.lon!)
        let spot = POIItem()
        spot.vehicleId = NSNumber(longLong: vehicle.id!)
        spot.position = pos
        if let regNumber = self.autosDict?[vehicle.id!]{
            spot.regNumber = "\(regNumber)"
        }
        if let azm = vehicle.azimut{
            spot.azimut = NSNumber(double: azm)
        }
        spot.name = "\(vehicle.id)"
        spot.hasAnimated = false
        return spot
    }
    
    //MARK: IBActions
    
    @IBAction func filter(sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(FILTER_STORYBOARD_ID)
        self.navigationController?.pushViewController(vc, animated: true)
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
        
        let vehicleId = item.vehicleId.longLongValue
        guard let auto = self.autosDict?[vehicleId] else { return NSBundle.mainBundle().loadNibNamed("MarkerWindow", owner: self, options: nil)[0] as? MarkerWindow }
        
        if let markerView = NSBundle.mainBundle().loadNibNamed("MarkerWindow", owner: self, options: nil)[0] as? MarkerWindow{
            markerView.company.text = auto.organization
            markerView.regNumber.text = auto.registrationNumber
            markerView.model.text = auto.model

            
            if let lastUpdate = auto.lastUpdate{
                let date = NSDate(timeIntervalSince1970: Double(lastUpdate))
                let dateFormatter = NSDateFormatter()
                dateFormatter.setLocalizedDateFormatFromTemplate("yyyy-MM-dd HH:mm:ss")
                markerView.lastUpdate.text = dateFormatter.stringFromDate(date)
            } else {
                markerView.lastUpdate.text = ""
            }
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
}
   