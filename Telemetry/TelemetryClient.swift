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
import SocketIOClientSwift

class TelemetryClient: NSObject {
    
    let SERVER_URL = "ws://stk.esmc.info:8084/telemetry/socket_server"
    
    var webSocket: SRWebSocket?
    let disposeBag = DisposeBag()
    
    var observableVehicles = PublishSubject<String>()
    
    init(token: String){
        super.init()

        self.webSocket = SRWebSocket(URL: NSURL(string: "ws://stk.esmc.info:8084/telemetry/socket_server"))
        self.webSocket!.open()
        
        self.webSocket!.rx_didOpen.subscribeNext { [weak self](val) in
            self?.webSocket!.send(VehiclesRequestSocket(_vehicles: true, _fullData: true, _token: token).getData() ?? NSData())
        }.addDisposableTo(self.disposeBag)
        
        self.webSocket?.rx_didReceiveMessage.map({ (object) -> String in
            print(object as! String)
            let js = JSON.parse(object as! String)
            var str = ""
            if let dict = js["vehicles"].dictionary{
                for(key, value) in dict{
                    str = str + key + ","
                }
            }
            
            return str
        }).subscribeNext({ (str) in
            self.observableVehicles.on(.Next(str))
        }).addDisposableTo(self.disposeBag)

    }

}
