//
//  MapVehiclesViewController.swift
//  Telemetry
//
//  Created by IMAC  on 12.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import RxSwift
import SocketRocket
import SwiftyJSON

class MapVehiclesViewController: UIViewController{
    
    var viewModel :VehiclesViewModel?
    let disposeBag = DisposeBag()
    
    var token: String?
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //viewModel = VehiclesViewModel(telemetryClient: TelemetryClient(token: token ?? ""))
        //self.addBindsToViewModel()
        let webSocket = SRWebSocket(URL: NSURL(string: "ws://stk.esmc.info:8084/telemetry/socket_server"))
        webSocket.open()
        webSocket.rx_didOpen.subscribeNext { (val) in
            if(val){
                webSocket!.send(VehiclesRequestSocket(_vehicles: true, _fullData: true, _token: self.token!).getData() ?? NSData())
            }
        }.addDisposableTo(self.disposeBag)
        webSocket.rx_didReceiveMessage.subscribeNext { (object) in
            print(JSON(object))
        }.addDisposableTo(self.disposeBag)
    }
    
    func addBindsToViewModel(){
        
        viewModel?.vehicles.bindTo(self.label.rx_text).addDisposableTo(self.disposeBag)
    }
    
    func webSocketDidOpen(webSocket: SRWebSocket!) {
        print("open")
    }

    func webSocket(webSocket: SRWebSocket!, didFailWithError error: NSError!) {
        print(error.description)
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceivePong pongPayload: NSData!) {
        
    }
    
    func webSocket(webSocket: SRWebSocket!, didReceiveMessage message: AnyObject!) {
        
    }
}


