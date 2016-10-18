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
import Alamofire

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
        
        let queue = DispatchQueue(label: "com.Telemetry.backgroundQueue",attributes: [])
        print(self.token)
        print(COMPANY_URL + "\(companyId ?? 0)")
        return requestJSON(.get, COMPANY_URL + "\(companyId ?? 0)", parameters: ["token": self.token ?? ""], encoding: URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
            .doOnError(onError: { (errType) in
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

