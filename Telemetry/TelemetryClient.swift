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
    
    let SERVER_URL = "ws://esmc.info/stk/api/v1/telemetry/socket_server"
    
    var webSocket: SRWebSocket?
    private var token: String?
    private var bounds: (first:(lat: String, lon: String), second: (lat: String, lon: String))?
    private var vehicles: [Int]?
    
    let disposeBag = DisposeBag()
    
    private var vehObservable = PublishSubject<Vehicles>()
    
    var vehiclesRequestSocket: VehiclesRequestSocket?
    
    init(token: String, bounds: (first:(lat: String, lon: String), second: (lat: String, lon: String))){
        super.init()
        
        self.webSocket = SRWebSocket(URL: NSURL(string: SERVER_URL))
        self.token = token
        self.bounds = bounds
        
        self.vehiclesRequestSocket = VehiclesRequestSocket(_token: token, _bounds: bounds)
    }
    
    //MARK: Modificators
    func setBounds(bounds: (first:(lat: String, lon: String), second: (lat: String, lon: String))){
        self.bounds = bounds
        self.vehiclesRequestSocket?.bounds = self.bounds!
    }
    
    func setVehicles(vehicles: [Int]){
        self.vehicles = vehicles
        self.vehiclesRequestSocket?.vehicles = vehicles
    }
    
    func isSocketOpen() -> Bool{
        if let state = self.webSocket?.readyState{
            if state == SRReadyState.OPEN{
                return true
            }
        }
        return false
    }
    
    func sendMessage(){
        self.webSocket!.send(self.vehiclesRequestSocket?.getData() ?? NSData())
        print(String(data: self.vehiclesRequestSocket?.getData() ?? NSData(), encoding: NSUTF8StringEncoding))
    }
    
    func closeSocket(){
        self.webSocket!.close()
    }
    
    func vehiclesObservable() -> Observable<Vehicles>{
        let backgrQueue = dispatch_queue_create("com.Telemetry.backgroundQueue", nil)
        
        self.webSocket!.rx_didOpen
            .observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue))
            .catchError({ (err)  -> Observable<Bool> in
                print((err as NSError).description)
                self.vehObservable.onError(APIError(errType: .NETWORK))
                return Observable.just(false)
            })
            .subscribeNext { [unowned self](val) in
                if(val){
                    self.webSocket!.send(self.vehiclesRequestSocket?.getData() ?? NSData())
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

                }).subscribe(onNext: { (veh, err) in
                    if(err.errType == APIErrorType.NONE){
                        self.vehObservable.on(.Next(veh))
                    } else {
                        self.vehObservable.onError(err)
                    }
                    }, onError: { (err) in
                        print((err as NSError).description)
                    }, onCompleted: { 
                        print("Completed")
                    }, onDisposed: { 
                        print("disposed")
                }).addDisposableTo(self.disposeBag)
        
        self.webSocket?.rx_didFailWithError
            .observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue))
            .subscribeNext({ (error) in
                print((error as NSError).description)
                self.vehObservable.onError(APIError(errType: .SOCKET_INTERRUPTED))
            }).addDisposableTo(self.disposeBag)
        
        dispatch_async(backgrQueue) {
            self.webSocket!.open()
        }
        
        return vehObservable
    }
    

}
