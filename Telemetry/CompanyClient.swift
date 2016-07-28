//
//  CompanyClient.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import RxAlamofire
import SwiftyJSON

class CompanyClient: NSObject {
    
    var token: String?
    var companyId: Int64?
    
    let COMPANY_URL = "http://gbutelemob.agentum.org/api/v1/organization/"
    
    init(_token: String, _companyId: Int64) {
        super.init()
        self.token = _token
        self.companyId = _companyId
    }
    
    func companyObservable() -> Observable<CompanyResponse>{
        
        let queue = dispatch_queue_create("tasksLoad",nil)
        print(self.token)
        print(COMPANY_URL + "\(companyId ?? 0)")
        return requestJSON(.GET, COMPANY_URL + "\(companyId ?? 0)", parameters: ["token": self.token ?? ""], encoding: .URL, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
            .doOnError({ (errType) in
                print(errType)
            })
            .map({ (response, object) -> CompanyResponse in
                let js = JSON(object)
                print(js)
                let compResponse = CompanyResponse(json: js)
                return compResponse
            })
    }
    
}

