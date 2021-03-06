//
//  VehiclesFilterClient.swift
//  Telemetry
//
//  Created by IMAC  on 04.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//
import RxSwift
import SocketRocket
import SwiftyJSON
import RxAlamofire

class VehiclesFilterClient: NSObject {

    var token: String?
    let VEHICLES_FILTER_URL = "http://gbutelemob.agentum.org/api/v1/vehicles/filter"
    
    init(_token: String){
        super.init()
        self.token = _token
    }
    
    func filterObservable() -> Observable<VehiclesFilterResponse>{
        
        let queue = dispatch_queue_create("tasksLoad",nil)
        
        return requestJSON(.GET, VEHICLES_FILTER_URL, parameters: ["token": self.token ?? ""], encoding: .URL, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
            .map({ (response, object) -> VehiclesFilterResponse in
                let js = JSON(object)
                print(js)
                let filterResponse = VehiclesFilterResponse(json: js)
                return filterResponse
            })
    }
}
