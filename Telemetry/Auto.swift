//
//  Auto.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

/*
 {
 
 "speed" : 1.27,
 "id" : 623,
 "registrationNumber" : "Ut ad adipisci minima quidem.",
 "model" : "Dicta sed omnis rerum.",
 "organization" : "Ea at labore et nemo autem.",
 "type" : "Qui mollitia vel eius.",
 "lastUpdate" : 1052771092
 
 } */
struct Auto {
    var id: Int64?
    var registrationNumber: String?
    var model: String?
    var organization: String?
    var lastUpdate: Int64?
    var speed: Double?
    var type: String?
    
    init(){
        
    }
    init(json: JSON){
        print(json)
        self.id = json["id"].int64
        self.registrationNumber = json["registrationNumber"].string
        self.model = json["model"].string
        self.organization = json["organization"].string
        self.lastUpdate = json["lastUpdate"].int64
        self.speed = json["speed"].double
        self.type = json["type"].string
    }
}