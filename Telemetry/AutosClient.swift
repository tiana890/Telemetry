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
import JASON
import Alamofire

class AutosClient: NSObject {
    
    var token: String?
    let AUTOS_URL = "http://gbutelemob.agentum.org/api/v1/vehicles"
    var local: Bool = false
    
    init(_token: String) {
        super.init()
        self.token = _token
    }
    
    func autosObservable() -> Observable<AutosResponse>{
        
        let queue = DispatchQueue(label: "com.Telemetry.backgroundQueue",attributes: [])

        return requestJSON(.get, AUTOS_URL, parameters: ["token": self.token ?? ""], encoding:  URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
            .map({ (response, object) -> AutosResponse in
                
                let js = SwiftyJSON.JSON(object)
                print(js)
                let autosResponse = AutosResponse(json: js)
                
                return autosResponse
            })
    }
    

    func autosDictJSONObservable() -> Observable<[String : SwiftyJSON.JSON]>{
        return requestJSON(.get, AUTOS_URL, parameters: ["token": self.token ?? ""], encoding:  URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ (response, object) -> [String: SwiftyJSON.JSON] in
                let js = SwiftyJSON.JSON(object)
                let start = Date().timeIntervalSince1970
                RealmManager.saveAutoJSONDict(js["vehicles"])
                let end = Date().timeIntervalSince1970 - start
                print(end)
                return [:]
            })
    }
    
    func autosIDsObservableWithFilter() -> Observable<[Int]>{
    
        let filterParams = ApplicationState.sharedInstance.filter?.getJSONString() ?? ""
        
        return requestJSON(.post, AUTOS_URL, parameters: ["filter":filterParams, "token": PreferencesManager.getToken() ?? ""], encoding: URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ (response, object) -> [Int] in
                print(JSON(object))
                let js = SwiftyJSON.JSON(object)
                let start = Date().timeIntervalSince1970
                let ids = RealmManager.saveAutoJSONDict(js["vehicles"])
                return ids
            })
    }
    
    func autosObservableWithFilter() -> Observable<[Auto]>{
        
        let filterParams = ApplicationState.sharedInstance.filter?.getJSONString() ?? ""
        
        return requestJSON(.post, AUTOS_URL, parameters: ["filter":filterParams, "token": PreferencesManager.getToken() ?? ""], encoding: URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ (response, object) -> [Auto] in
                let js = SwiftyJSON.JSON(object)
                var arr: [Auto] = []
                for (key,subJson):(String, SwiftyJSON.JSON) in js["vehicles"] {
                    arr.append(Auto(json: subJson))
                }
                return arr
            })
    }

    
}

