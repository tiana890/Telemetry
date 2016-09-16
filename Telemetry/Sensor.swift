//
//  Sensor.swift
//  Telemetry
//
//  Created by IMAC  on 08.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Sensor {
    var id: Int64?
    var name: String?
    
    init(json: JSON){
        self.id = json["id"].int64
        self.name = json["name"].string
    }
}
