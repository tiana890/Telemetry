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
    private var autosClient: AutosClient
    
    //output
    var autos = PublishSubject<[Auto]>()
    
    //MARK: Set up
    
    init(_autosClient: AutosClient){
        self.autosClient = _autosClient
        
//        let backgrQueue = dispatch_queue_create("com.Telemetry.companies.backgroundQueue", nil)
//        autosClient.autosDictObservable().observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue)).map { (autosResponse) -> [Auto] in
//            if let dict = autosResponse.autosDict{
//                let arr = Array(dict.values)
//                return arr as [Auto]
//            }
//            return []
//            }.bindTo(autos).addDisposableTo(self.disposeBag)
    }
    
    func getAutosObservable() -> Observable<[Auto]>{
        let backgrQueue = dispatch_queue_create("com.Telemetry.companies.backgroundQueue", nil)
        return autosClient
            .autosDictObservable()
            .observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue))
            .map { (autosResponse) -> [Auto] in
                if let dict = autosResponse.autosDict{
                    let arr = Array(dict.values)
                    return arr as [Auto]
                }
                return []
            }
    }
}