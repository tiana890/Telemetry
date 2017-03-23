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
 
 id: 399,
 model: "К060КА777",
 type: "Аварийно-техническая",
 garage_number: "",
 speed: 0,
 lastUpdate: 0,
 organization_id: 95,
 organization: "АО "Мосводоканал"
 
 } */
struct Auto {
    var id: Int?
    var registrationNumber: String?
    var garageNumber: String?
    var organization: String?
    var organizationId: Int?
    var lastUpdate: Int64?
    var speed: Double?
    var type: String?
    var model: String?
    
    init(){
        
    }
    
    init(entity: AutoEntity){
        self.id = entity.id
        self.registrationNumber = entity.regNumber
        self.garageNumber = entity.garageNumber
        self.model = entity.model
        self.organization = entity.organization
        self.organizationId = entity.organizationId
        self.lastUpdate = Int64(entity.lastUpdate)
        self.speed = Double(entity.speed)
        self.type = entity.type
    }
    
    init(json: SwiftyJSON.JSON){
        self.id = json["id"].int
        self.registrationNumber = json["registration_number"].string
        self.garageNumber = json["garage_number"].string
        self.model = json["model"].string
        self.organization = json["organization"].string
        self.lastUpdate = json["lastUpdate"].int64
        self.organizationId = json["organization_id"].int
        self.speed = json["speed"].double
        self.type = json["type"].string
    }
    
    init(json: JASON.JSON){
        self.id = json["id"].int ?? 0
        self.registrationNumber = json["registrationNumber"].string
        self.garageNumber = json["garageNumber"].string
        self.model = json["model"].string
        self.organization = json["organization"].string
        self.lastUpdate = Int64(json["lastUpdate"].int ?? 0)
        self.speed = json["speed"].double
        self.type = json["type"].string
    }
}
