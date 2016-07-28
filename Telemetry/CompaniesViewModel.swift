//
//  OrganizationViewModel.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift


final class CompaniesViewModel{
    
    private let disposeBag = DisposeBag()
    
    //output
    var companies = PublishSubject<[Company]>()
    
    //MARK: Set up
    init(companiesClient: CompaniesClient){
        
        let backgrQueue = dispatch_queue_create("com.Telemetry.companies.backgroundQueue", nil)

        companiesClient.companiesObservable().observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue)).map { (companiesResponse) -> [Company] in
            return companiesResponse.companies ?? []
        }.bindTo(companies).addDisposableTo(self.disposeBag)
        
    }
}