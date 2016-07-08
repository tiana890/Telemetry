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

    init(_vehicles: Bool, _fullData: Bool){
        self.vehicles = _vehicles
        self.fullData = _fullData
    }
    
    func getData() -> NSData?{
        let json = JSON(dictionaryLiteral: ("vehicles", vehicles), ("fulldata", fullData))
        return try! json.rawData()
    }
}
