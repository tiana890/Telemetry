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

class TelemetryClient: NSObject, SRWebSocketDelegate {
    
    let SERVER_URL = "ws://stk.esmc.info:8084/telemetry/socket_server"
    
    var webSocket: SRWebSocket?
    let disposeBag = DisposeBag()
    
    var observableVehicles: Observable<String>?
    override init(){
        super.init()

        self.webSocket = SRWebSocket(URL: NSURL(string: "ws://stk.esmc.info:8084/telemetry/socket_server"))
        self.webSocket?.open()
        self.webSocket!.rx_didOpen.subscribeNext { [weak self](val) in
            self?.webSocket!.send(VehiclesRequestSocket(_vehicles: true, _fullData: true).getData() ?? NSData())
        }.addDisposableTo(self.disposeBag)
        self.observableVehicles = self.getVehicles()
    }
    
    func getVehicles() -> Observable<String>{

        return self.webSocket!.rx_didReceiveMessage.map({ (object) -> String in
            
            let js = JSON.parse(object as! String)
            var str = ""
            print(js["vehicles"])
            if let dict = js["vehicles"].dictionary{
                for(key, value) in dict{
                    str = key + ","
                }
            }
            
            return str
        })

    }

    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        print("didOpen")
        
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print(reason)
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceivePong pongPayload: NSData!) {
        print("Pong")
    }
}
