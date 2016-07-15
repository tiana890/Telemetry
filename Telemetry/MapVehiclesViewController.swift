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
    
    var dict = [Int64: (mapInfo: VehicleMapInfo, marker: GMSMarker)]()
    
    
    @IBOutlet weak var mapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = VehiclesViewModel(telemetryClient: TelemetryClient(token: token ?? ""))
        self.addBindsToViewModel()
    }
    
    func addBindsToViewModel(){
        viewModel?.vehiclesMetaInfo.subscribeNext({ [unowned self](mapInfoArr) in
            self.appendMarkersOnMap(mapInfoArr)
        }).addDisposableTo(self.disposeBag)
    }
    
    func appendMarkersOnMap(array: [VehicleMapInfo]){
        //Find current markers in dict
        for(vehicleMapInfo) in array{
            if let value = dict[vehicleMapInfo.id]{
                if(value.mapInfo.lat == vehicleMapInfo.lat && value.mapInfo.lon == vehicleMapInfo.lon){
                    
                } else {
                    let marker = value.marker
                    dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, marker: marker)
                    dispatch_async(dispatch_get_main_queue(), {
                        marker.position = CLLocationCoordinate2D(latitude: vehicleMapInfo.lat, longitude: vehicleMapInfo.lon)
                    })
                }
            } else {
                let gmsMapMarker = GMSMarker()
                dict[vehicleMapInfo.id] = (mapInfo: vehicleMapInfo, marker: gmsMapMarker)
                gmsMapMarker.position = CLLocationCoordinate2D(latitude: vehicleMapInfo.lat, longitude: vehicleMapInfo.lon)
                dispatch_async(dispatch_get_main_queue(), { 
                    gmsMapMarker.map = self.mapView
                })
                
            }
        }
    }
    
    
}


