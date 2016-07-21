
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

    
    let mapQueue = dispatch_queue_create("com.Telemetry.backgroundQueue", nil)
    
    override func viewDidLoad() {
        
        mapView = GMSMapView(frame: self.view.frame)
        self.view.addSubview(mapView!)
        
        viewModel = VehiclesViewModel(telemetryClient: TelemetryClient(token: token ?? ""))
        self.addBindsToViewModel()
        
        // Set up the cluster manager with default icon generator and renderer.
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView!, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView!, algorithm: algorithm, renderer: renderer)
        self.mapView!.delegate = self
        
        // Register self to listen to both GMUClusterManagerDelegate and GMSMapViewDelegate events.
        clusterManager.setDelegate(self, mapDelegate: self)
    }
    
    func addBindsToViewModel(){

        viewModel?.vehiclesMetaInfo.observeOn(ConcurrentDispatchQueueScheduler(queue: mapQueue)).subscribeNext({ [unowned self](mapInfoArr) in
            
            self.appendMarkersOnMap(mapInfoArr)
                
            
            dispatch_async(dispatch_get_main_queue(), {
                self.clusterManager?.cluster()
                
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
                    dispatch_barrier_async(self.mapQueue, {
                        self.clusterManager.removeItem(value.spot)
                    })
                    
                    let spot = addMarkerAndCreateSpot(vehicleMapInfo)
                    dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, spot: spot)
                    
                    dispatch_barrier_async(self.mapQueue, {
                        self.clusterManager.addItem(spot)
                    })
                }
            } else {
                let spot = addMarkerAndCreateSpot(vehicleMapInfo)
                dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, spot: spot)
                dispatch_barrier_async(self.mapQueue, {
                    self.clusterManager.addItem(spot)
                })
            }
        }
        
    }
    
    func addMarkerAndCreateSpot(vehicleMapInfo: VehicleMapInfo) -> POIItem{
        let pos = CLLocationCoordinate2D(latitude: vehicleMapInfo.lat, longitude: vehicleMapInfo.lon)
        let spot = POIItem(position: pos, name: "\(vehicleMapInfo.id)")
        return spot
    }
}
    /****************************************************************************************************/
    
//    var viewModel :VehiclesViewModel?
//    let disposeBag = DisposeBag()
//    
//    var token: String?
//    
//    var dict = [Int64: (mapInfo: VehicleMapInfo, spot: Spot)]()
//    
//    var v: GMSMapView?
//    
//    var clusterAlgorithm: NonHierarchicalDistanceBasedAlgorithm?
//    var clusterManager: GClusterManager?
//    
//    //@IBOutlet weak var mapView: GMSMapView!
//    let mapQueue = dispatch_queue_create("com.Telemetry.backgroundQueue", nil)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        viewModel = VehiclesViewModel(telemetryClient: TelemetryClient(token: token ?? ""))
//        self.addBindsToViewModel()
//        
//        v = GMSMapView(frame: self.view.frame)
//        self.view.addSubview(v!)
//        
//        self.clusterAlgorithm = NonHierarchicalDistanceBasedAlgorithm()
//        self.clusterManager = GClusterManager(mapView: self.v, algorithm: self.clusterAlgorithm, renderer: GDefaultClusterRenderer(mapView: self.v))
//    
//    }
//    
//    func addBindsToViewModel(){
//        
//        viewModel?.vehiclesMetaInfo.observeOn(ConcurrentDispatchQueueScheduler(queue: mapQueue)).subscribeNext({ [unowned self](mapInfoArr) in
//            dispatch_barrier_async(self.mapQueue, {
//                self.appendMarkersOnMap(mapInfoArr)
//            })
//            //self.clusterManager?.removeItemsNotInRectangle(self.v!.frame)
//            self.clusterManager?.cluster()
//        }).addDisposableTo(self.disposeBag)
//    }
//    
//    func appendMarkersOnMap(array: [VehicleMapInfo]){
//
//        //Find current markers in dict
//        for(vehicleMapInfo) in array{
//            if let value = dict[vehicleMapInfo.id]{
//                if(value.mapInfo.lat == vehicleMapInfo.lat && value.mapInfo.lon == vehicleMapInfo.lon){
//                    print("not changed")
//                } else {
//                    //change items in cluster manager
//                    print(self.clusterManager?.items?.count)
//                    guard let index = self.clusterAlgorithm?.items.map({ ($0 as! GQuadItem).marker }).indexOf(value.spot.marker) else { break}
//                    
//                    let spot = addMarkerAndCreateSpot(vehicleMapInfo)
//                    dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, spot: spot)
//                    
//                    self.clusterAlgorithm?.items.removeObjectAtIndex(index)
//                    
//                    self.addSpot(spot)
//                    
//                }
//            } else {
//                let spot = addMarkerAndCreateSpot(vehicleMapInfo)
//                dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, spot: spot)
//                self.addSpot(spot)
//            }
//        }
//
//    }
//    
//    func addMarkerAndCreateSpot(vehicleMapInfo: VehicleMapInfo) -> Spot{
//        let gmsMapMarker = GMSMarker()
//        let pos = CLLocationCoordinate2D(latitude: vehicleMapInfo.lat, longitude: vehicleMapInfo.lon)
//        gmsMapMarker.position = pos
//        let spot = Spot(_position: pos, _marker: gmsMapMarker)
//        return spot
//    }
//    
//    func addSpot(spot: Spot){
//        self.clusterManager?.addItem(spot)
//    }
    
//}


