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
    
    var token: String?
    var filter: Filter?
    
    let companiesPath = "/api/v1/organizations"
    
    init(_token: String) {
        super.init()
        self.token = _token
    }
    
    func companiesObservable() -> Observable<CompaniesResponse>{

        var parameters = [String: Any]()
        let path = PreferencesManager.getAPIServer() + companiesPath
        
        if let _ = self.filter{
            parameters["filter"] = ["name": self.filter?.companyName ?? ""]
        }
        
        return requestJSON(.post, path + "?token=" + (self.token ?? ""), parameters: parameters, encoding: JSONEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ (response, object) -> CompaniesResponse in
                print(response)
                let js = JSON(object)
                print(js)
                let compResponse = CompaniesResponse(json: js)
                return compResponse
            })
    }
    
    
    
}

