
/*******************************************************************************************/
import UIKit
import RxSwift
import SwiftyJSON
import GoogleMaps

class MapVehiclesViewController: BaseViewController, GMUClusterManagerDelegate, GMSMapViewDelegate{

    let kClusterItemCount = 10000
    
    var mapView: GMSMapView?
    
    private var clusterManager: GMUClusterManager!
    
    var dict = [Int64: (mapInfo: VehicleMapInfo, spot: POIItem)]()
    
    var viewModel :VehiclesViewModel?
    var token: String?

    var algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    
    let mapQueue = dispatch_queue_create("com.Telemetry.backgroundQueue", nil)
    
    //MARK: IBOutlets
    
    @IBAction func menuPressed(sender: AnyObject) {
        ApplicationState.sharedInstance().showLeftPanel()
    }
    
    override func viewDidLoad() {
        
        mapView = GMSMapView(frame: self.view.frame)
        self.view.addSubview(mapView!)
        
        viewModel = VehiclesViewModel(telemetryClient: TelemetryClient(token: ApplicationState.sharedInstance().token ?? ""))
        
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView!, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView!, algorithm: algorithm, renderer: renderer)
        self.mapView!.delegate = self
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.addBindsToViewModel()
    }
    
    func addBindsToViewModel(){

        let sub = viewModel?.vehiclesMetaInfo.observeOn(MainScheduler.instance).subscribeNext({ [unowned self](mapInfoArr) in

            dispatch_barrier_async(dispatch_get_main_queue(), {
                self.appendMarkersOnMap(mapInfoArr)
                self.clusterManager.cluster()
            })
            
        })
        addSubscription(sub!)
    }

    func appendMarkersOnMap(array: [VehicleMapInfo]){

        //Find current markers in dict
        for(vehicleMapInfo) in array{
            if let value = dict[vehicleMapInfo.id]{
                if(value.mapInfo.lat == vehicleMapInfo.lat && value.mapInfo.lon == vehicleMapInfo.lon){
                    
                } else {
                    self.clusterManager.removeItem(value.spot)
                    
                    let spot = addMarkerAndCreateSpot(vehicleMapInfo)
                    spot.prevLon = String(value.spot.position.longitude)
                    spot.prevLat = String(value.spot.position.latitude)
                    dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, spot: spot)
                    self.clusterManager.addItem(spot)
                }
                
            } else {
                let spot = addMarkerAndCreateSpot(vehicleMapInfo)
                spot.prevLat = nil
                spot.prevLon = nil
                dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, spot: spot)
                self.clusterManager.addItem(spot)
            }
        }
    }
    
    func addMarkerAndCreateSpot(vehicleMapInfo: VehicleMapInfo) -> POIItem{
        let pos = CLLocationCoordinate2D(latitude: vehicleMapInfo.lat, longitude: vehicleMapInfo.lon)
        let spot = POIItem()
        spot.position = pos
        spot.name = "\(vehicleMapInfo.id)"
        return spot
    }
}
   