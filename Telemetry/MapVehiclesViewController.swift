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
    
    var clusterManager: GClusterManager?
    
    //@IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = VehiclesViewModel(telemetryClient: TelemetryClient(token: token ?? ""))
        self.addBindsToViewModel()
        
        v = GMSMapView(frame: self.view.frame)
        self.view.addSubview(v!)
        
        self.clusterManager = GClusterManager(mapView: self.v, algorithm: NonHierarchicalDistanceBasedAlgorithm(), renderer: GDefaultClusterRenderer(mapView: self.v))
    
    }
    
    func addBindsToViewModel(){
        let mapQueue = dispatch_queue_create("com.Telemetry.backgroundQueue", nil)
        viewModel?.vehiclesMetaInfo.observeOn(ConcurrentDispatchQueueScheduler(queue: mapQueue)).subscribeNext({ [unowned self](mapInfoArr) in
            self.appendMarkersOnMap(mapInfoArr)
            
        }).addDisposableTo(self.disposeBag)
    }
    
    func appendMarkersOnMap(array: [VehicleMapInfo]){

        //Find current markers in dict
        for(vehicleMapInfo) in array{
            if let value = dict[vehicleMapInfo.id]{
                if(value.mapInfo.lat == vehicleMapInfo.lat && value.mapInfo.lon == vehicleMapInfo.lon){
                    
                } else {
//                    let spot = Spot
//                    dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, marker: marker)
//                    dispatch_async(dispatch_get_main_queue(), {
//                        marker.position = CLLocationCoordinate2D(latitude: vehicleMapInfo.lat, longitude: vehicleMapInfo.lon)
//                    })
                }
            } else {
                let gmsMapMarker = GMSMarker()
                let pos = CLLocationCoordinate2D(latitude: vehicleMapInfo.lat, longitude: vehicleMapInfo.lon)
                gmsMapMarker.position = pos
                let spot = Spot(_position: pos, _marker: gmsMapMarker)
                dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, spot: spot)

                dispatch_async(dispatch_get_main_queue(), {
        
                    self.addSpot(spot)
                })
                
            }
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.clusterManager?.cluster()
        })
    }
    
    func addSpot(spot: Spot){
        self.clusterManager?.addItem(spot)

    }
    
}


