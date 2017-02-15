//
//  OrganizationClient.swift
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

class CompaniesClient: NSObject{
    
    /*
     {
     status: "success",
     code: 200,
     "organizations": {
     "12": [
     {
     id: 12,
     short_name: "АвД",
     name: "ГБУ "Автомобильные дороги""
     },
     ...
     ],
     ...
     }
     }
     */
    
    var token: String?
    var filter: Filter?
    
    let companiesPath = "/stk/api/v1/telemetry/organization_list"
    
    init(_token: String) {
        super.init()
        self.token = _token
    }
    
    func companiesObservable() -> Observable<CompaniesResponse>{

        var parameters = [String: Any]()
        let path = PreferencesManager.getAPIServer() + companiesPath
        
//        if let _ = self.filter{
//            parameters["filter"] = ["name": self.filter?.companyName ?? ""]
//        }
        parameters["auth_token"] = self.token ?? ""
        return requestJSON(.get, path, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ (response, object) -> CompaniesResponse in
                let js = JSON(object)
                let compResponse = CompaniesResponse(json: js)
                return compResponse
            })
        

    }
    
    
    
}

