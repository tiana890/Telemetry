//
//  MapViewModel.swift
//  Telemetry
//
//  Created by Agentum on 07.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift

struct VehicleMapInfo{
    var id: Int64
    var lat: Double
    var lon: Double
}

final class VehiclesViewModel{
    
    private let disposeBag = DisposeBag()
    
    //output
    var vehiclesMetaInfo = PublishSubject<[VehicleMapInfo]>()
    
    //MARK: Set up
    init(telemetryClient: TelemetryClient){
    
        //telemetryClient.observableVehicles.bindTo(vehicles).addDisposableTo(self.disposeBag)
        
        telemetryClient.observableVehicles.map { (veh) -> [VehicleMapInfo] in
            var arr = [VehicleMapInfo]()
            for(vehicle) in veh.array{
                if(vehicle.id != nil && vehicle.lat != nil && vehicle.lon != nil){
                    arr.append(VehicleMapInfo(id: vehicle.id!, lat: vehicle.lat!, lon: vehicle.lon!))
                }
            }
            return arr
        }.bindTo(vehiclesMetaInfo).addDisposableTo(self.disposeBag)
        
    }
    
}
