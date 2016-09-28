//
//  RxGoogleMapsDelegateProxy.swift
//  Telemetry
//
//  Created by Agentum on 15.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import RxSwift
import RxCocoa
import GoogleMaps

class RxGoogleMapsDelegateProxy: DelegateProxy, DelegateProxyType, GMSMapViewDelegate {
    
    let didChangeCameraPosition = PublishSubject<GMSCameraPosition>()
    
    static func currentDelegateFor(object: AnyObject) -> AnyObject?{
        let googleMap: GMSMapView = object as! GMSMapView
        return googleMap.delegate
    }
    
    static func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let googleMap: GMSMapView = object as! GMSMapView
        googleMap.delegate = delegate as? GMSMapViewDelegate
    }
    
    func mapView(mapView: GMSMapView, didChangeCameraPosition position: GMSCameraPosition) {
        didChangeCameraPosition.on(.Next(position))
    }
}

extension GMSMapView{
    public var rx_delegate: DelegateProxy{
        return RxGoogleMapsDelegateProxy.proxyForObject(self)
    }
    
    public var rx_didChangeCameraPosition: Observable<GMSCameraPosition>{
        let proxy = RxGoogleMapsDelegateProxy.proxyForObject(self)
        return proxy.didChangeCameraPosition
    }
}