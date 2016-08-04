//
//  VehiclesFilterViewModel.swift
//  Telemetry
//
//  Created by IMAC  on 04.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import RxSwift
import UIKit

final class VehiclesFilterViewModel{
    
    private let disposeBag = DisposeBag()
    
    //output
    var filterDict = PublishSubject<FilterDict>()
    
    //MARK: Set up
    init(filterClient: VehiclesFilterClient){
        
        let backgrQueue = dispatch_queue_create("com.Telemetry.companies.backgroundQueue", nil)
    
        filterClient.filterObservable().observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue)).map { (filterResponse) -> FilterDict in
            return filterResponse.filterDict ?? FilterDict()
        }.bindTo(filterDict).addDisposableTo(self.disposeBag)

    }
}