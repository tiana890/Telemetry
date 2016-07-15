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
import Action

final class AuthorizationViewModel{
    

    private let disposeBag = DisposeBag()
    
    //input
    var login = PublishSubject<String>()
    var password = PublishSubject<String>()
    var didPressButton = PublishSubject<Void>()
    //output
    var authModel:Observable<Auth> = Observable.never()

    
    init(authClient: AuthClient){
        
        let userInputs = Observable.combineLatest(login, password) { (login, password) -> (String, String) in
            return (login, password)
        }
        
        authModel = didPressButton
                    .withLatestFrom(userInputs)
                    .asObservable()
                    .flatMap({ (log, pass) -> Observable<AuthResponse> in
                        return authClient.authObservable(log, mergedHash: "\(log):\(pass)".md5)
                    })
                    .map({ (authResponse) -> Auth in
                        return self.convertAuthResponseToAuthModel(authResponse)
                    })

    }


    func convertAuthResponseToAuthModel(authResponse: AuthResponse) -> Auth{
        var authModel = Auth()
        authModel.token = authResponse.token
        return authModel
    }
}
