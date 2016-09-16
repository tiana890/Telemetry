//
//  CompanyViewModel.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift


final class CompanyViewModel{
    
    private let disposeBag = DisposeBag()
    
    //output
    var company = PublishSubject<Company>()
    
    //MARK: Set up
    init(companyClient: CompanyClient){
        
        let backgrQueue = dispatch_queue_create("com.Telemetry.companies.backgroundQueue", nil)
        
        companyClient.companyObservable().observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue)).map { (compResponse) -> Company in
            return compResponse.company ?? Company()
        }.bindTo(company).addDisposableTo(self.disposeBag)
        
    }
}