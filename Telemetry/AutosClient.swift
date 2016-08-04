//
//  VehiclesClient.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import RxAlamofire
import SwiftyJSON

class AutosClient: NSObject {
    
    var token: String?
    let AUTOS_URL = "http://gbutelemob.agentum.org/api/v1/vehicles"
    
    init(_token: String) {
        super.init()
        self.token = _token
    }
    
    func autosObservable() -> Observable<AutosResponse>{
        
        let queue = dispatch_queue_create("com.Telemetry.backgroundQueue",nil)
        print(AUTOS_URL)
        print(self.token ?? "")
        return requestJSON(.GET, AUTOS_URL, parameters: ["token": self.token ?? ""], encoding: .URL, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
            .map({ (response, object) -> AutosResponse in
                let js = JSON(object)
                print(js)
                let autosResponse = AutosResponse(json: js)
                return autosResponse
            })
    }
    
    func autosDictObservable() -> Observable<AutosDictResponse>{
        let queue = dispatch_queue_create("com.Telemetry.backgroundQueue",nil)
        print(AUTOS_URL)
        print(self.token ?? "")
        return requestJSON(.GET, AUTOS_URL, parameters: ["token": self.token ?? ""], encoding: .URL, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
            .map({ (response, object) -> AutosDictResponse in
                let js = JSON(object)
                print(js)
                let autosDictResponse = AutosDictResponse(json: js)
                return autosDictResponse
            })
    }
    
}

