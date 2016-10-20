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
    
    let companyPath = "http://gbutelemob.agentum.org/api/v1/organization/"
    
    init(_token: String, _companyId: Int64) {
        super.init()
        self.token = _token
        self.companyId = _companyId
    }
    
    func companyObservable() -> Observable<CompanyResponse>{
        let path = PreferencesManager.getAPIServer() + companyPath
        
        return requestJSON(.get, path + "\(companyId ?? 0)", parameters: ["token": self.token ?? ""], encoding: URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onError: { (errType) in
                print(errType)
            })
            .map({ (response, object) -> CompanyResponse in
                let js = JSON(object)
                let compResponse = CompanyResponse(json: js)
                return compResponse
            })
    }
    
}

