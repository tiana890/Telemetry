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

class RxSocketManagerDelegateProxy: DelegateProxy, DelegateProxyType, SRWebSocketDelegate{
    
    static func currentDelegateFor(object: AnyObject) -> AnyObject?{
        let socket: SRWebSocket = object as! SRWebSocket
        return socket.delegate
    }
    
    static func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let socket: SRWebSocket = object as! SRWebSocket
        socket.delegate = delegate as? SRWebSocketDelegate
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        print(self._forwardToDelegate)
    }
}

extension SRWebSocket{
    public var rx_delegate: DelegateProxy{
        return RxSocketManagerDelegateProxy.proxyForObject(self)
    }
    
    public var rx_didReceiveMessage: Observable<AnyObject>{
        return rx_delegate.observe(#selector(SRWebSocketDelegate.webSocket(_:didReceiveMessage:))).map({ (arr) in
            guard(arr.count > 0) else { return "" }
            return arr[0]
         })
    }
    
    public var rx_didOpen: Observable<Bool>{
        return rx_delegate.observe(#selector(SRWebSocketDelegate.webSocketDidOpen(_:))).map({ (obj) -> Bool in
            return true
        })
    }
        
}