//
//  Auto.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON
import JASON

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
    var id: Int?
    var registrationNumber: String?
    var model: String?
    var organization: String?
    var lastUpdate: Int64?
    var speed: Double?
    var type: String?
    
    init(){
        
    }
    init(json: SwiftyJSON.JSON){
        self.id = json["id"].int
        self.registrationNumber = json["registrationNumber"].string
        self.model = json["model"].string
        self.organization = json["organization"].string
        self.lastUpdate = json["lastUpdate"].int64
        self.speed = json["speed"].double
        self.type = json["type"].string
    }
    
    init(json: JASON.JSON){
        self.id = json["id"].int ?? 0
        self.registrationNumber = json["registrationNumber"].string
        self.model = json["model"].string
        self.organization = json["organization"].string
        self.lastUpdate = Int64(json["lastUpdate"].int ?? 0)
        self.speed = json["speed"].double
        self.type = json["type"].string
    }
}