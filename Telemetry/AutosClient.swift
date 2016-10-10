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

class AutosClient: NSObject {
    
    var token: String?
    let AUTOS_URL = "http://gbutelemob.agentum.org/api/v1/vehicles"
    var local: Bool = false
    
    init(_token: String) {
        super.init()
        self.token = _token
    }
    
    func autosObservable() -> Observable<AutosResponse>{
        
        let queue = dispatch_queue_create("com.Telemetry.backgroundQueue",nil)

        return requestJSON(.GET, AUTOS_URL, parameters: ["token": self.token ?? ""], encoding: .URL, headers: nil)
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
        return requestJSON(.GET, AUTOS_URL, parameters: ["token": self.token ?? ""], encoding: .URL, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .map({ (response, object) -> [String: SwiftyJSON.JSON] in
                let js = SwiftyJSON.JSON(object)
                let start = NSDate().timeIntervalSince1970
                RealmManager.saveAutoJSONDict(js["vehicles"])
                let end = NSDate().timeIntervalSince1970 - start
                print(end)
                return [:]
            })
    }
    
    func autosIDsObservableWithFilter() -> Observable<[Int]>{
    
        let filterParams = ApplicationState.sharedInstance().filter?.getJSONString() ?? ""
        
        return requestJSON(.POST, AUTOS_URL, parameters: ["filter":filterParams, "token": PreferencesManager.getToken() ?? ""], encoding: .URL, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
            .map({ (response, object) -> [Int] in
                print(JSON(object))
                let js = SwiftyJSON.JSON(object)
                let start = NSDate().timeIntervalSince1970
                let ids = RealmManager.saveAutoJSONDict(js["vehicles"])
                return ids
            })
    }
    
    func autosObservableWithFilter() -> Observable<[Auto]>{
        
        let filterParams = ApplicationState.sharedInstance().filter?.getJSONString() ?? ""
        
        return requestJSON(.POST, AUTOS_URL, parameters: ["filter":filterParams, "token": PreferencesManager.getToken() ?? ""], encoding: .URL, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background))
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

