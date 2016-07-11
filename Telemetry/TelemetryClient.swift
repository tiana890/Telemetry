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
    
    var socket: SocketIOClient?
    
    var observableVehicles: Observable<String>?
    override init(){
        super.init()
        
//        socket = SocketIOClient(socketURL: NSURL(string: SERVER_URL)!, options: [.Log(true), .ForcePolling(true)])
//        
////        socket?.emit("send", withItems: [VehiclesRequestSocket(_vehicles: true, _fullData: true).getData() ?? NSData()])
////        socket?.on("send", callback: { (arr, ackEmitter) in
////            print(arr)
////        })
//        socket?.on("send", callback: { [weak self](arr, emitter) in
//            print(arr)
//            
//        })
//
//        socket?.connect()
//        //connect()
//     }
//    
//    func connect(){
//        var i = 0
//        repeat{
//        self.socket?.emit("send", VehiclesRequestSocket(_vehicles: true, _fullData: true).getData() ?? NSData())
//        } while (i == 0)
//    }

        let webSocket = SRWebSocket(URL: NSURL(string: "ws://stk.esmc.info:8084/telemetry/socket_server"))
        webSocket.delegate = self
        webSocket.open()
    }

    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        let js = JSON.parse(message as! String)
        var str = ""
        print(js["vehicles"])
        if let dict = js["vehicles"].dictionary{
            for(key, value) in dict{
                str = key + ","
            }
        }
        self.observableVehicles = Observable.create({ (observer) -> Disposable in
            observer.onNext(str)
            return AnonymousDisposable{
                
            }
        })
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        print("didOpen")
        webSocket.send(VehiclesRequestSocket(_vehicles: true, _fullData: true).getData() ?? NSData())
    }
    
    func webSocket(webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print(reason)
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceivePong pongPayload: NSData!) {
        print("Pong")
    }
}
