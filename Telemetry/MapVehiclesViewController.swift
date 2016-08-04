
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
    
    //MARK: IBOutlets
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBAction func menuPressed(sender: AnyObject) {
        ApplicationState.sharedInstance().showLeftPanel()
    }
    
    override func viewDidLoad() {
        
        mapView = GMSMapView(frame: self.view.frame)
        self.view.addSubview(mapView!)
        
        self.indicator.startAnimating()
        viewModel = VehiclesViewModel(telemetryClient: TelemetryClient(token: ApplicationState.sharedInstance().getToken() ?? ""))
        
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView!, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView!, algorithm: algorithm, renderer: renderer)
        self.mapView!.delegate = self
        
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
        spot.position = pos
        if let regNumber = ApplicationState.sharedInstance().autosDict?[vehicle.id!]{
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
}
   