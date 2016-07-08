//
//  TelemetryClient.swift
//  Telemetry
//
//  Created by Agentum on 08.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import RxSwift
import SocketRocket

class TelemetryClient: NSObject, SRWebSocketDelegate {
    
    override init(){
        super.init()
        
        let webSocket = SRWebSocket(URL: NSURL(string: "ws://stk.esmc.info:8084/telemetry/socket_server"))
        webSocket.delegate = self
        webSocket.open()
        
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        print(message)
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
