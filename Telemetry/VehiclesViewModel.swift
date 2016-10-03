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
        telemetryClient.vehiclesObservable().observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue))
            .bindTo(vehicles).addDisposableTo(self.disposeBag)
    }
    
    
    
}
