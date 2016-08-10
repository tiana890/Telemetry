//
//  TrackViewModel.swift
//  Telemetry
//
//  Created by IMAC  on 10.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//
import UIKit
import RxSwift

final class TrackViewModel{
    
    private let disposeBag = DisposeBag()
    
    //output
    var track = PublishSubject<Track>()
    
    //MARK: Set up
    init(trackClient: TrackClient){
        
        let backgrQueue = dispatch_queue_create("com.Telemetry.companies.backgroundQueue", nil)
        
        trackClient.trackObservable().observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue)).map { (trackResponse) -> Track in
            return trackResponse.track ?? Track()
        }.bindTo(track).addDisposableTo(self.disposeBag)
        
    }
}