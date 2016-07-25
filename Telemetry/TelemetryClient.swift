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
    
    let SERVER_URL = "ws://esmc.info/stk//api/v1/telemetry/socket_server"
    
    var webSocket: SRWebSocket?
    let disposeBag = DisposeBag()
    
    var observableVehicles = PublishSubject<Vehicles>()
    
    init(token: String){
        super.init()
        
        let backgrQueue = dispatch_queue_create("com.Telemetry.backgroundQueue", nil)

        
        //self.webSocket = SRWebSocket(URL: NSURL(string: "ws://stk.esmc.info:8084/telemetry/socket_server"))
        self.webSocket = SRWebSocket(URL: NSURL(string: SERVER_URL))
        
        dispatch_async(backgrQueue) {
            self.webSocket!.open()
        }
        
        self.webSocket!.rx_didOpen.observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue)).subscribeNext { [weak self](val) in
            self?.webSocket!.send(VehiclesRequestSocket(_vehicles: true, _fullData: true, _token: token).getData() ?? NSData())
        }.addDisposableTo(self.disposeBag)
        
        self.webSocket?.rx_didReceiveMessage.observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue)).map({ (object) -> Vehicles in
            
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
                }
            }
            return vehicles
            
        }).observeOn(ConcurrentDispatchQueueScheduler(queue: backgrQueue))
            .subscribeNext({ (veh) in
            self.observableVehicles.on(.Next(veh))
        }).addDisposableTo(self.disposeBag)
        

    }

}
