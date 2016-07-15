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
    var vehicles = PublishSubject<String>()
    
    //MARK: Set up
    init(telemetryClient: TelemetryClient){
    
        telemetryClient.observableVehicles.bindTo(vehicles).addDisposableTo(self.disposeBag)
   
    }
    
}
