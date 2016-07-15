//
//  Vehicle.swift
//  Telemetry
//
//  Created by Agentum on 08.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

class Vehicle: NSObject {
    var id: Int64?
    var companyProviderId: Int64?
    var sensorId: Int64?
    var azimut: Float64?
    var speed: Float64?
    var odometr: Float64?
    var lat: Float64?
    var lon: Float64?
    var sta: String?
    var tsk: String?
    var dateObserved: Int64?
    var dateReceived: Int64?
    var registrationNumber: String?
    
    init(json: JSON){
        super.init()
        
        self.id = json["v_id"].int64
        self.companyProviderId = json["p_id"].int64
        self.sensorId = json["s_id"].int64
        self.azimut = json["azm"].double
        self.speed = json["spe"].double
        self.odometr = json["odo"].double
        self.lat = json["lat"].double
        self.lon = json["lon"].double
        self.sta = json["sta"].string
        self.tsk = json["tsk"].string
        self.dateObserved = json["dt_o"].int64
        self.dateReceived = json["dt_r"].int64
        
    }
}
