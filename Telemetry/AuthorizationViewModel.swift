//
//  AuthorizationViewModel.swift
//  Telemetry
//
//  Created by Agentum on 13.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift

final class AuthorizationViewModel{
    
    private let authAPIService: AuthAPIService
    private let disposeBag = DisposeBag()
    
    init(){
       authAPIService = AuthAPIService()
        
    }
}
