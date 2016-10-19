//
//  InfoClient.swift
//  Telemetry
//
//  Created by Пользователь on 19.10.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import RxAlamofire
import SwiftyJSON
import Alamofire

class InfoClient: NSObject {
    
    var token: String?
    
    let INFO_URL = "http://gbutelemob.agentm.org/api/v1/common/server"
    
    init(_token: String) {
        super.init()
        self.token = _token
    }
    
    func infoObservable() -> Observable<InfoResponse>{
        
        return requestJSON(.get, INFO_URL, parameters: ["token": self.token ?? ""], encoding: URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ (response, object) -> InfoResponse in
                print()
                let js = JSON(object)
                print(js)
                let infoResponse = InfoResponse(json: js)
                return infoResponse
            })
    }
    
}
