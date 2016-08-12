//
//  TelemetryClient.swift
//  Telemetry
//
//  Created by Agentum on 08.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import RxSwift
import SocketRocket
import SwiftyJSON


class TelemetryClient: NSObject {
    
    let SERVER_URL = "ws://esmc.info/stk//api/v1/telemetry/socket_server1"
    
    var webSocket: SRWebSocket?
    var token: String?
    let disposeBag = DisposeBag()
    
    private var vehObservable = PublishSubject<Vehicles>()
    
    init(token: String){
        super.init()
        self.webSocket = SRWebSocket(URL: NSURL(string: SERVER_URL))
    }
    
    func vehiclesObservable() -> Observable<Vehicles>{
        let backgrQueue = dispatch_queue_create("com.Telemetry.backgroundQueue", nil)
        
        
        self.webSocket!.rx_didOpen
            .observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue))
            .catchError({ (err)  -> Observable<Bool> in
                self.vehObservable.onError(APIError(errType: .NETWORK))
                return Observable.just(false)
            })
            .subscribeNext { [unowned self](val) in
                if(val){
                    self.webSocket!.send(VehiclesRequestSocket(_vehicles: true, _fullData: true, _token: self.token ?? "").getData() ?? NSData())
                } else {
                    self.vehObservable.onError(APIError(errType: .UNKNOWN))
                }
            }
            .addDisposableTo(self.disposeBag)
        
        self.webSocket?.rx_didReceiveMessage
            .observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue))
            .catchError({ (err) -> Observable<AnyObject> in
                return Observable.just(APIError(errType: .NETWORK))
            })
            .map({ (object) -> (Vehicles, APIError) in
            
                var vehicles = Vehicles()
                if let str = object as? String{
                    let js = JSON.parse(str)
                    
                    if let dict = js["vehicles"].dictionary {
                        for(key, value) in dict{
                            let vehicleModel = Vehicle(json: value)
                            if let intKey = Int64(key){
                                vehicleModel.id = intKey
                                vehicles.array.append(vehicleModel)
                            }
                        }
                        return (vehicles, APIError(errType: .NONE))
                    } else if let error = js["error"].string{
                        let apiError = APIError(_errCode: js["code"].int, _reason: js["reason"].string)
                        return (vehicles, apiError)
                    }
                }
                return (vehicles, APIError(errType: .UNKNOWN))
            
        }).subscribeNext({ (veh, err) in
            if(err.errType == APIErrorType.NONE){
                self.vehObservable.on(.Next(veh))
            } else {
                self.vehObservable.onError(err)
            }
        }).addDisposableTo(self.disposeBag)
        
        self.webSocket?.rx_didFailWithError
            .observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue))
            .subscribeNext({ (error) in
                self.vehObservable.onError(APIError(errType: .NETWORK))
            }).addDisposableTo(self.disposeBag)
        
        dispatch_async(backgrQueue) {
            self.webSocket!.open()
        }
        
        return vehObservable
    }
    

}
