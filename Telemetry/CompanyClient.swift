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
    
    let companyPath = "/stk/api/v1/telemetry/organization/"
    
    init(_token: String, _companyId: Int64) {
        super.init()
        self.token = _token
        self.companyId = _companyId
    }
    
    func companyObservable() -> Observable<CompanyResponse>{
        let path = PreferencesManager.getAPIServer() + companyPath
        print(path)
        return requestJSON(.get, path + "\(companyId ?? 0)", parameters: ["auth_token": self.token ?? ""], encoding: URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onError: { (errType) in
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

