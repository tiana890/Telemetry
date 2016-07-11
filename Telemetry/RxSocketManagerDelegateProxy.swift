//
//  RxSocketManagerDelegateProxy.swift
//  Telemetry
//
//  Created by Agentum on 11.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import RxSwift
import RxCocoa
import SocketRocket

class RxSocketManagerDelegateProxy: DelegateProxy, DelegateProxyType{
    
    static func currentDelegateFor(object: AnyObject) -> AnyObject?{
        let socket: SRWebSocket = object as! SRWebSocket
        return socket.delegate
    }
    
    static func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let socket: SRWebSocket = object as! SRWebSocket
        socket.delegate = delegate as? SRWebSocketDelegate
    }

}

extension SRWebSocket{
    public var rx_delegate: DelegateProxy{
        return DelegateProxyType.proxyForObject(RxSocketManagerDelegateProxy.self)
    }
    
}