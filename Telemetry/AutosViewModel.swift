//
//  AutosViewModel.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift


final class AutosViewModel{
    
    private let disposeBag = DisposeBag()
    
    //output
    var autos = PublishSubject<[Auto]>()
    
    //MARK: Set up
    init(autosClient: AutosClient){
        
        let backgrQueue = dispatch_queue_create("com.Telemetry.companies.backgroundQueue", nil)
        autosClient.autosObservable().observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue)).map { (autosResponse) -> [Auto] in
            return autosResponse.autos ?? []
            }.bindTo(autos).addDisposableTo(self.disposeBag)
    }
}