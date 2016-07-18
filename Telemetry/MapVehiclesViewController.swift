//
//  MapVehiclesViewController.swift
//  Telemetry
//
//  Created by IMAC  on 12.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyJSON
import GoogleMaps

class MapVehiclesViewController: UIViewController{
    
    var viewModel :VehiclesViewModel?
    let disposeBag = DisposeBag()
    
    var token: String?
    
    var dict = [Int64: (mapInfo: VehicleMapInfo, spot: Spot)]()
    
    var v: GMSMapView?
    
    var clusterAlgorithm: NonHierarchicalDistanceBasedAlgorithm?
    var clusterManager: GClusterManager?
    
    //@IBOutlet weak var mapView: GMSMapView!
    let mapQueue = dispatch_queue_create("com.Telemetry.backgroundQueue", nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = VehiclesViewModel(telemetryClient: TelemetryClient(token: token ?? ""))
        self.addBindsToViewModel()
        
        v = GMSMapView(frame: self.view.frame)
        self.view.addSubview(v!)
        
        self.clusterAlgorithm = NonHierarchicalDistanceBasedAlgorithm()
        self.clusterManager = GClusterManager(mapView: self.v, algorithm: self.clusterAlgorithm, renderer: GDefaultClusterRenderer(mapView: self.v))
    
    }
    
    func addBindsToViewModel(){
        
        viewModel?.vehiclesMetaInfo.observeOn(ConcurrentDispatchQueueScheduler(queue: mapQueue)).subscribeNext({ [unowned self](mapInfoArr) in
            dispatch_barrier_async(self.mapQueue, {
                self.appendMarkersOnMap(mapInfoArr)
            })
            //self.clusterManager?.removeItemsNotInRectangle(self.v!.frame)
            self.clusterManager?.cluster()
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
                    print(self.clusterManager?.items?.count)
                    guard let index = self.clusterAlgorithm?.items.map({ ($0 as! GQuadItem).marker }).indexOf(value.spot.marker) else { break}
                    
                    let spot = addMarkerAndCreateSpot(vehicleMapInfo)
                    dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, spot: spot)
                    
                    self.clusterAlgorithm?.items.removeObjectAtIndex(index)
                    
                    self.addSpot(spot)
                    
                }
            } else {
                let spot = addMarkerAndCreateSpot(vehicleMapInfo)
                dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, spot: spot)
                self.addSpot(spot)
            }
        }

    }
    
    func addMarkerAndCreateSpot(vehicleMapInfo: VehicleMapInfo) -> Spot{
        let gmsMapMarker = GMSMarker()
        let pos = CLLocationCoordinate2D(latitude: vehicleMapInfo.lat, longitude: vehicleMapInfo.lon)
        gmsMapMarker.position = pos
        let spot = Spot(_position: pos, _marker: gmsMapMarker)
        return spot
    }
    
    func addSpot(spot: Spot){
        self.clusterManager?.addItem(spot)
    }
    
}


