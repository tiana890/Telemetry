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
import Alamofire

class VehiclesFilterClient: NSObject {

    var token: String?
    let vehiclesFilterPath = "/api/v1/vehicles/filter"
    
    init(_token: String){
        super.init()
        self.token = _token
    }
    
    func filterObservable() -> Observable<VehiclesFilterResponse>{
        
//        let path = PreferencesManager.getAPIServer() + vehiclesFilterPath
//        
//        
//        return requestJSON(.get, path, parameters: ["token": self.token ?? ""], encoding: URLEncoding.default, headers: nil)
//            .debug()
//            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
//            .map({ (response, object) -> VehiclesFilterResponse in
//                let js = JSON(object)
//                let filterResponse = VehiclesFilterResponse(json: js)
//                return filterResponse
//            })
        
        let filterResponse = VehiclesFilterResponse()
        filterResponse.filterDict?.companies = RealmManager.getCompanies()
        filterResponse.filterDict?.models = []
        return Observable.just(filterResponse)
        
    }
}
