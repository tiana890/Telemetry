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

class CompaniesClient: NSObject{
    
    var token: String?
    var filter: Filter?
    let COMPANIES_URL = "http://gbutelemob.agentum.org/api/v1/organizations"
    
    init(_token: String) {
        super.init()
        self.token = _token
    }
    
    func companiesObservable() -> Observable<CompaniesResponse>{
        
        let queue = dispatch_queue_create("com.Telemetry.backgroundQueue",nil)
        
        var parameters = [String: AnyObject]()
        //parameters["token"] = self.token ?? ""
        if let _ = self.filter{
            parameters["filter"] = ["name": self.filter?.companyName ?? ""]
        }

        return requestJSON(.POST, COMPANIES_URL + "?token=" + (self.token ?? ""), parameters: parameters, encoding: .JSON, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
            .map({ (response, object) -> CompaniesResponse in
                print(response)
                let js = JSON(object)
                print(js)
                let compResponse = CompaniesResponse(json: js)
                return compResponse
            })
    }
    
    
    
}

