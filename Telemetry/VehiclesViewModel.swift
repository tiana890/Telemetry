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
    
    //MARK: Model
    let vehicles: Observable<String>

    //MARK: Set up
    init(telemetryClient: TelemetryClient){
        vehicles = telemetryClient.getVehicles()
    }
    
}
