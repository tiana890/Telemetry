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
    
    fileprivate let disposeBag = DisposeBag()
    
    //output
    var track = PublishSubject<Track>()
    
    //MARK: Set up
    init(trackClient: TrackClient){
        
        let backgrQueue = DispatchQueue(label: "com.Telemetry.companies.backgroundQueue", attributes: [])
        
        trackClient.trackObservable().observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue)).map { (trackResponse) -> Track in
            return trackResponse.track ?? Track()
        }.bindTo(track).addDisposableTo(self.disposeBag)
        
    }
}
