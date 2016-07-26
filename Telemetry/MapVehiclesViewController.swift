
/*******************************************************************************************/
import UIKit
import RxSwift
import SwiftyJSON
import GoogleMaps

class MapVehiclesViewController: UIViewController, GMUClusterManagerDelegate, GMSMapViewDelegate{

    let kClusterItemCount = 10000
    
    var mapView: GMSMapView?
    
    private var clusterManager: GMUClusterManager!
    
    var dict = [Int64: (mapInfo: VehicleMapInfo, spot: POIItem)]()
    
    var viewModel :VehiclesViewModel?
    let disposeBag = DisposeBag()
    var token: String?

    var algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    
    let mapQueue = dispatch_queue_create("com.Telemetry.backgroundQueue", nil)
    
    override func viewDidLoad() {
        
        mapView = GMSMapView(frame: self.view.frame)
        self.view.addSubview(mapView!)
        
        viewModel = VehiclesViewModel(telemetryClient: TelemetryClient(token: ApplicationState.sharedInstance().token ?? ""))
        self.addBindsToViewModel()
        
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView!, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView!, algorithm: algorithm, renderer: renderer)
        self.mapView!.delegate = self
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    func addBindsToViewModel(){

        viewModel?.vehiclesMetaInfo.observeOn(MainScheduler.instance).subscribeNext({ [unowned self](mapInfoArr) in

            dispatch_barrier_async(dispatch_get_main_queue(), {
                self.appendMarkersOnMap(mapInfoArr)
                self.clusterManager.cluster()
            })
            
        }).addDisposableTo(self.disposeBag)
    }

    func appendMarkersOnMap(array: [VehicleMapInfo]){

        //Find current markers in dict
        for(vehicleMapInfo) in array{
            if let value = dict[vehicleMapInfo.id]{
                if(value.mapInfo.lat == vehicleMapInfo.lat && value.mapInfo.lon == vehicleMapInfo.lon){
                    
                } else {
                    //change items in cluster manager
                    //value.spot.position = CLLocationCoordinate2D(latitude: vehicleMapInfo.lat, longitude: vehicleMapInfo.lon)
                    
                    self.clusterManager.removeItem(value.spot)
                    
                    let spot = addMarkerAndCreateSpot(vehicleMapInfo)
                    if(value.spot.nextLat != nil && value.spot.nextLon != nil){
                        spot.position = CLLocationCoordinate2D(latitude: Double(value.spot.nextLat)!, longitude: Double(value.spot.nextLon)!)
                        
                        spot.currentLat = value.spot.nextLat
                        spot.currentLon = value.spot.nextLon
                    } else {
                        spot.position = value.spot.position
                        
                        spot.currentLat = "\(value.spot.position.latitude)"
                        spot.currentLon = "\(value.spot.position.longitude)"
                    }
                    spot.nextLat = "\(vehicleMapInfo.lat)"
                    spot.nextLon = "\(vehicleMapInfo.lon)"
                    
                    dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, spot: spot)
                    self.clusterManager.addItem(spot)

                }
            } else {
                let spot = addMarkerAndCreateSpot(vehicleMapInfo)
                dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, spot: spot)
                self.clusterManager.addItem(spot)
            }
        }
    }
    
    func addMarkerAndCreateSpot(vehicleMapInfo: VehicleMapInfo) -> POIItem{
        let pos = CLLocationCoordinate2D(latitude: vehicleMapInfo.lat, longitude: vehicleMapInfo.lon)
        let spot = POIItem()
        spot.position = pos
        spot.currentLat = "\(pos.latitude)"
        spot.currentLon = "\(pos.longitude)"
        spot.name = "\(vehicleMapInfo.id)"
        return spot
    }
}
   