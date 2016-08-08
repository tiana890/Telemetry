//
//  AutoViewModel.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift

final class AutoViewModel{
    
    private let disposeBag = DisposeBag()
    
    //output
    var auto = PublishSubject<AutoDetail>()
    
    //MARK: Set up
    init(autoClient: AutoClient){
        
        let backgrQueue = dispatch_queue_create("com.Telemetry.companies.backgroundQueue", nil)
        
        autoClient.companyObservable().observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue)).map { (autoResponse) -> AutoDetail in
            return autoResponse.autoDetail ?? AutoDetail()
            }.bindTo(auto).addDisposableTo(self.disposeBag)

        
    }
}