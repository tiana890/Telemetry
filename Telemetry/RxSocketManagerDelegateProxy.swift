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
import SwiftyJSON

class RxSocketManagerDelegateProxy: DelegateProxy, DelegateProxyType, SRWebSocketDelegate{
    
    let didReceiveMessageSubject = PublishSubject<Any>()
    let didOpenSubject = PublishSubject<Bool>()
    let didFailWithErrorSubject = PublishSubject<NSError>()
    
    static func currentDelegateFor(_ object: AnyObject) -> AnyObject?{
        let socket: SRWebSocket = object as! SRWebSocket
        return socket.delegate
    }
    
    static func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let socket: SRWebSocket = object as! SRWebSocket
        socket.delegate = delegate as? SRWebSocketDelegate
    }
    
    
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        didOpenSubject.on(.next(true))
        //(self._forwardToDelegate as! RxSocketManagerDelegateProxy).webSocketDidOpen(webSocket)
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        didFailWithErrorSubject.on(.next(error))
    }
    
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print(code)
        //didReceiveMessageSubject.on(.Completed)
    }
    
    public func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        didReceiveMessageSubject.on(.next(message))
        //(self._forwardToDelegate as! RxSocketManagerDelegateProxy).webSocket(webSocket, didReceiveMessage: message)
    }

    
    
}

extension SRWebSocket{
    public var rx_delegate: DelegateProxy{
        return RxSocketManagerDelegateProxy.proxyForObject(self)
    }
    
    public var rx_didReceiveMessage: Observable<Any>{
        let proxy = RxSocketManagerDelegateProxy.proxyForObject(self)
        return proxy.didReceiveMessageSubject
    }
    
    public var rx_didOpen: Observable<Bool>{
        let proxy = RxSocketManagerDelegateProxy.proxyForObject(self)
        return proxy.didOpenSubject
    }
    
    public var rx_didFailWithError: Observable<NSError>{
        let proxy = RxSocketManagerDelegateProxy.proxyForObject(self)
        return proxy.didFailWithErrorSubject
    }
        
}
