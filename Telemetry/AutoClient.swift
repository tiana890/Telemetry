//
//  AutoClient.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import RxAlamofire
import SwiftyJSON

class AutoClient: NSObject {
    
    var token: String?
    var autoId: Int64?
    
    let AUTO_URL = "http://gbutelemob.agentum.org/api/v1/vehicle/"
    
    init(_token: String, _autoId: Int64) {
        super.init()
        self.token = _token
        self.autoId = _autoId
    }
    
    func companyObservable() -> Observable<AutoResponse>{
        
        let queue = dispatch_queue_create("com.Telemetry.backgroundQueue",nil)

        return requestJSON(.GET, AUTO_URL + "\(autoId ?? 0)", parameters: ["token": self.token ?? ""], encoding: .URL, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
            .doOnError({ (errType) in
                print(errType)
            })
            .map({ (response, object) -> AutoResponse in
                let js = JSON(object)
                print(js)
                let autoResponse = AutoResponse(json: js)
                return autoResponse
            })
    }
    
}

