//
//  BaseCollectionViewController.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BaseCollectionViewController: UICollectionViewController {
    var disposeBag : DisposeBag?
    
    func addSubscription(_ subscription: Disposable){
        if(self.disposeBag == nil){
            self.disposeBag = DisposeBag()
        }
        disposeBag?.addDisposable(subscription)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.disposeBag = nil
    }
    
    deinit{
        print("DEINIT DISPOSABLE")
        self.disposeBag = nil
    }
}
