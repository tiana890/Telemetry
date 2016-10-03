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

class AuthClient: NSObject {
    
    let AUTH_URL = "http://gbutelemob.agentum.org/api/v1/auth"
    
    func authObservable(login: String, password: String) -> Observable<AuthResponse>{
        
        let paramDict = ["login" : login, "password" : "\(login):\(password)".md5]
        let queue = dispatch_queue_create("tasksLoad",nil)
        
        return requestJSON(.POST, AUTH_URL, parameters: paramDict, encoding: .URL, headers: nil)
            .debug()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
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
