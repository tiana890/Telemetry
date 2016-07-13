//
//  AuthorizationViewController.swift
//  Telemetry
//
//  Created by Agentum on 13.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift

class AuthorizationViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let authClient = AuthClient()
        authClient.authObservable("", mergedHash: "")
            .subscribeNext { (response) in
                print(response.status)
                print(response.reason)
                
        }.addDisposableTo(self.disposeBag)
    }
    
}
