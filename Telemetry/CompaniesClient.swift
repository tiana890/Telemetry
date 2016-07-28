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

class CompaniesClient: NSObject {
    
    var token: String?
    let COMPANIES_URL = "http://gbutelemob.agentum.org/api/v1/organizations"
    
    init(_token: String) {
        super.init()
        self.token = _token
    }
    
    func companiesObservable() -> Observable<CompaniesResponse>{
        
        let queue = dispatch_queue_create("tasksLoad",nil)
        
        return requestJSON(.POST, COMPANIES_URL, parameters: ["token": self.token ?? ""], encoding: .URL, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
            .map({ (response, object) -> CompaniesResponse in
                let js = JSON(object)
                print(js)
                let compResponse = CompaniesResponse(json: js)
                return compResponse
            })
    }
    
}

