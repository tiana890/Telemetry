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
    var autoId: Int64?
    var startTime: String?
    var endTime: String?
    
    let TRACK_URL = "http://gbutelemob.agentum.org/api/v1/vehicle/track/"
    
    init(_token: String, _autoId: Int64, _startTime: Int64, _endTime: Int64) {
        super.init()
        self.token = _token
        self.autoId = _autoId
        self.startTime = "\(_startTime)"
        self.endTime = "\(_endTime)"
    }
    
    func trackObservable() -> Observable<TrackResponse>{
        
        let queue = DispatchQueue(label: "com.Telemetry.backgroundQueue",attributes: [])
        
        let parameters = ["token": self.token ?? "",
                          "startTime": self.startTime ?? "",
                          "endTime": self.endTime ?? ""]
        print(TRACK_URL + "\(autoId ?? 0)")

       
        
        return requestJSON(.get, TRACK_URL + "\(autoId ?? 0)", parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .observeOn(ConcurrentDispatchQueueScheduler(queue: queue))
            .catchError({ (errType) -> Observable<(HTTPURLResponse, Any)> in
                print(errType)
                return Observable.just((HTTPURLResponse(coder: NSCoder())!, ""))
            })
            .map({ (response, object) -> TrackResponse in
                print(response)
                let js = JSON(object)
                print(js)
                let trackResponse = TrackResponse(json: js)
                return trackResponse
            })

    }
    


}
