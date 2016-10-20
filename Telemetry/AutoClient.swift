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
import Alamofire

class AutoClient: NSObject {
    
    var token: String?
    var autoId: Int64?
    
    let autoPath = "/api/v1/vehicle/"
    
    init(_token: String, _autoId: Int64) {
        super.init()
        self.token = _token
        self.autoId = _autoId
    }
    
    func companyObservable() -> Observable<AutoDetailResponse>{
        let path = PreferencesManager.getAPIServer() + autoPath
        
        return requestJSON(.get, path + "\(autoId ?? 0)", parameters: ["token": self.token ?? ""], encoding: URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ (response, object) -> AutoDetailResponse in
                print()
                let js = JSON(object)
                print(js)
                let autoResponse = AutoDetailResponse(json: js)
                return autoResponse
            })
    }
    
}

