//
//  VehiclesRequestSocket.swift
//  Telemetry
//
//  Created by Agentum on 08.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

class VehiclesRequestSocket{
    
    private var vehicles: Bool
    private var fullData: Bool
    private var token: String

    init(_vehicles: Bool, _fullData: Bool, _token: String){
        self.vehicles = _vehicles
        self.fullData = _fullData
        self.token = _token
    }
    
    func getData() -> NSData?{
        let json = JSON(dictionaryLiteral: ("vehicles", [6222,5467,7180,3296]), ("auth_token", token))
        return try! json.rawData()
    }
}
