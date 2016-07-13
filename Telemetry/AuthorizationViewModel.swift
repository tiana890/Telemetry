//
//  AuthorizationViewModel.swift
//  Telemetry
//
//  Created by Agentum on 13.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import SwiftyJSON

final class AuthorizationViewModel{
    
    private let authClient: AuthClient
    private let disposeBag = DisposeBag()
    
    private let authModel: Auth
    
    let authEvent = Variable(UIControlEvents.TouchUpInside)
    let login = Variable(String)
    let password = Variable(String)
    
    init(){
       authClient = AuthClient()
    
       authModel = authEvent.asObservable()
                .flatMapLatest({ (events) -> Observable<Auth> in
                    return authClient.authObservable(login.value, mergedHash: password.value)
                        .
                })
    }
    
}
