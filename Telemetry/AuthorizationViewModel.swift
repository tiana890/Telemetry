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
    
    private let disposeBag = DisposeBag()
    
    //output
    var authModel:Observable<Auth>?

    var dataLoader = DataLoader<AuthResponse>()
    
    var authClient: AuthClient
    
    init(authClient: AuthClient){
        self.authClient = authClient
    
    }

    func authorize(login: String, password: String) -> Observable<Auth>{
        return authClient.authObservable(login, password: password)
            .map({ (authResponse) -> Auth in
                return self.convertAuthResponseToAuthModel(authResponse)
            })
    }

    func convertAuthResponseToAuthModel(authResponse: AuthResponse) -> Auth{
        var authModel = Auth()
        authModel.token = authResponse.token
        authModel.reason = authResponse.reason
        return authModel
    }
    
    
}
