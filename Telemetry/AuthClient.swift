//
//  AuthClient.swift
//  Telemetry
//
//  Created by Agentum on 13.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import RxAlamofire
import SwiftyJSON
import Alamofire

class AuthClient: NSObject {
    
    let AUTH_URL = "http://gbutelemob.agentum.org/api/v1/auth"
    
    func authObservable(_ login: String, password: String) -> Observable<AuthResponse>{
        
        let paramDict: [String: String] = ["login" : login, "password" : "\(login):\(password)".md5]
        let queue = DispatchQueue(label: "tasksLoad",attributes: [])
        print(paramDict)
        return requestJSON(.post, AUTH_URL, parameters: paramDict, encoding: URLEncoding.default, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map({ (response, object) -> AuthResponse in
                let js = JSON(object)
                print(js)
                let authResponse = AuthResponse(json: js)
                return authResponse
            })
            .catchError({ (err) -> Observable<AuthResponse> in
                return Observable.just(AuthResponse())
            })
        
    }
    
}
