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
    
    let didReceiveMessageSubject = PublishSubject<AnyObject>()
    let didOpenSubject = PublishSubject<Bool>()
    let didFailWithErrorSubject = PublishSubject<NSError>()
    
    static func currentDelegateFor(object: AnyObject) -> AnyObject?{
        let socket: SRWebSocket = object as! SRWebSocket
        return socket.delegate
    }
    
    static func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let socket: SRWebSocket = object as! SRWebSocket
        socket.delegate = delegate as? SRWebSocketDelegate
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        print(JSON(message))
        didReceiveMessageSubject.on(.Next(message))
        
        //(self._forwardToDelegate as! RxSocketManagerDelegateProxy).webSocket(webSocket, didReceiveMessage: message)
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        didOpenSubject.on(.Next(true))
        //(self._forwardToDelegate as! RxSocketManagerDelegateProxy).webSocketDidOpen(webSocket)
    }
    
    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        didFailWithErrorSubject.on(.Next(error))
        
    }
    

}

extension SRWebSocket{
    public var rx_delegate: DelegateProxy{
        return RxSocketManagerDelegateProxy.proxyForObject(self)
    }
    
    public var rx_didReceiveMessage: Observable<AnyObject>{
        let proxy = RxSocketManagerDelegateProxy.proxyForObject(self)
        return proxy.didReceiveMessageSubject
    }
    
    public var rx_didOpen: Observable<Bool>{
        let proxy = RxSocketManagerDelegateProxy.proxyForObject(self)
        return proxy.didOpenSubject
//        return rx_delegate.observe(#selector(SRWebSocketDelegate.webSocketDidOpen(_:))).map({ (obj) -> Bool in
//            return true
//        })
    }
    
    public var rx_didFailWithError: Observable<NSError>{
        let proxy = RxSocketManagerDelegateProxy.proxyForObject(self)
        return proxy.didFailWithErrorSubject
    }
        
}