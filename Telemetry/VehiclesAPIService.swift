//
//  VehiclesAPIService.swift
//  Telemetry
//
//  Created by Agentum on 08.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import SocketRocket

class VehiclesAPIService: NSObject {
    let telemetryClient = TelemetryClient()
    
    func getVehicles() -> Observable<Vehicles>{
        return telemetryClient.vehiclesObservable
    }
    
}
