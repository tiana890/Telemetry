
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

    var algorithm = GMUGridBasedClusterAlgorithm()
    
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
                    print("not changed")
                } else {
                    //change items in cluster manager
                    
                    self.clusterManager.removeItem(value.spot)
                    
                    let spot = addMarkerAndCreateSpot(vehicleMapInfo)
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
        let spot = POIItem(position: pos, name: "\(vehicleMapInfo.id)")
        return spot
    }
}
   