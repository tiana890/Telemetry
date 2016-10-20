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
    let autosPath = "/api/v1/vehicles"
    var local: Bool = false
    
    init(_token: String) {
        super.init()
        self.token = _token
    }
    
    func autosObservable() -> Observable<AutosResponse>{
        let path = PreferencesManager.getAPIServer() + autosPath
        
        return requestJSON(.get, path, parameters: ["token": self.token ?? ""], encoding:  URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ (response, object) -> AutosResponse in
                let js = SwiftyJSON.JSON(object)
                let autosResponse = AutosResponse(json: js)
                return autosResponse
            })
    }
    

    func autosDictJSONObservable() -> Observable<[String : SwiftyJSON.JSON]>{
        let path = PreferencesManager.getAPIServer() + autosPath

        return requestJSON(.get, path, parameters: ["token": self.token ?? ""], encoding:  URLEncoding.default, headers: nil)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ (response, object) -> [String: SwiftyJSON.JSON] in
                let jsonObject = JSON(object)["vehicles"]
                let start = Date().timeIntervalSince1970
                print(jsonObject.type)
                RealmManager.saveAutoJSONDict(jsonObject)
                let end = Date().timeIntervalSince1970 - start
                print(end)
                return [:]
            })
    }
    
    func autosIDsObservableWithFilter() -> Observable<[Int]>{
    
        let filterParams = ApplicationState.sharedInstance.filter?.getJSONString() ?? ""
        let path = PreferencesManager.getAPIServer() + autosPath
        return requestJSON(.post, path, parameters: ["filter":filterParams, "token": PreferencesManager.getToken() ?? ""], encoding: URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ (response, object) -> [Int] in
                let js = SwiftyJSON.JSON(object)
                let ids = RealmManager.saveAutoJSONDict(js["vehicles"])
                return ids
            })
    }
    
    func autosObservableWithFilter() -> Observable<[Auto]>{
        
        let filterParams = ApplicationState.sharedInstance.filter?.getJSONString() ?? ""
        let path = PreferencesManager.getAPIServer() + autosPath
        return requestJSON(.post, path, parameters: ["filter":filterParams, "token": PreferencesManager.getToken() ?? ""], encoding: URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ (response, object) -> [Auto] in
                let jsonObject = JSON(object)["vehicles"]
                var arr: [Auto] = []
                for (key,subJson):(String, SwiftyJSON.JSON) in jsonObject.dictionaryValue {
                    arr.append(Auto(json: subJson))
                }
                return arr
            })
    }

    
}

