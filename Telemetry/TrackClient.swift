//
//  TrackClient.swift
//  Telemetry
//
//  Created by IMAC  on 10.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//
import RxAlamofire
import RxSwift
import RxCocoa
import SwiftyJSON
import Alamofire

class TrackClient: NSObject {

    var token: String?
    var autoId: Int?
    var startTime: String?
    var endTime: String?
    
    let trackPath = "/api/v1/vehicle/track/"
    
    init(_token: String, _autoId: Int, _startTime: Int64, _endTime: Int64) {
        super.init()
        self.token = _token
        self.autoId = _autoId
        self.startTime = "\(_startTime)"
        self.endTime = "\(_endTime)"
    }
    
    func trackObservable() -> Observable<TrackResponse>{
        let path = PreferencesManager.getAPIServer() + trackPath
        
        let parameters = ["token": self.token ?? "",
                          "startTime": self.startTime ?? "",
                          "endTime": self.endTime ?? ""]
        print(path + "\(autoId ?? 0)")

       
        return requestJSON(.get, path + "\(autoId ?? 0)", parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMap({ (response, object) -> Observable<TrackResponse> in
                let js = JSON(object)
                
                let trackResponse = TrackResponse(json: js)
                if(trackResponse.status == Status.Success){
                    return Observable.just(trackResponse)
                } else {
                    return self.createObserverOnError(APIError(_errType: .UNKNOWN, _reason: trackResponse.reason ?? ""))
                }
        })
            
    }
    
    internal func createObserverOnError(_ apiError: APIError) -> Observable<TrackResponse>{
        return Observable.create({ (observer) -> Disposable in
            observer.onError(apiError)
            return Disposables.create {}
        })
    }

}
