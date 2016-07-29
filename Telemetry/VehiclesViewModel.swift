//
//  MapViewModel.swift
//  Telemetry
//
//  Created by Agentum on 07.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift


final class VehiclesViewModel{
    
    private let disposeBag = DisposeBag()
    
    //output
    var vehicles = PublishSubject<Vehicles>()
    
    //MARK: Set up
    init(telemetryClient: TelemetryClient){

        let backgrQueue = dispatch_queue_create("com.Telemetry.backgroundQueue", nil)
        telemetryClient.observableVehicles.observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue))//.map { (veh) -> [VehicleMapInfo] in
//            var arr = [VehicleMapInfo]()
//            for(vehicle) in veh.array{
//                if(vehicle.id != nil && vehicle.lat != nil && vehicle.lon != nil){
//                    arr.append(VehicleMapInfo(id: vehicle.id!, lat: vehicle.lat!, lon: vehicle.lon!))
//                }
//            }
//            return arr
//        }
            .bindTo(vehicles).addDisposableTo(self.disposeBag)
        
    }
    
}
