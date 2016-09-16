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
    
    init(authClient: AuthClient, withLogin login: Observable<String>, password: Observable<String>, didPressButton: Observable<Void>){
        
        let userInputs = Observable.combineLatest(login, password) { (login, password) -> (String, String) in
            return (login, password)
        }
        
        
        
//        authModel = dataLoader.load(didPressButton
//                    .withLatestFrom(userInputs)
//                    .debug()
//                    .flatMap({ (log, pass) -> Observable<AuthResponse> in
//                        return authClient.authObservable(log, password: pass)
//                    }))
//                    .map({ (authResponse) -> Auth in
//                        return self.convertAuthResponseToAuthModel(authResponse)
//                    })
        authModel = didPressButton
                            .asObservable()
                            .withLatestFrom(userInputs)
                            .debug()
                            .flatMap({ (log, pass) -> Observable<AuthResponse> in
                                return authClient.authObservable(log, password: pass)
                            })
//                            .catchError({ (errType) -> Observable<AuthResponse> in
//                                return Observable.error(APIError(errType: .NETWORK))
//                            })
//                            .flatMap({ (element) -> Observable<AuthResponse> in
//                                let status = element.status ?? Status.Error
//                                if(status == Status.Success){
//                                    return Observable.just(element)
//                                } else {
//                                    return Observable.error(APIError(_errType: .UNKNOWN, _reason: element.reason))
//                                }
//                            })
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
