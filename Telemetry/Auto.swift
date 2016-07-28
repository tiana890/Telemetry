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
 
     "id": 0,
     "registrationNumber": "string",
     "model": "string",
     "modelName": "string",
     "group": "string",
     "organization": "string",
     "glonasId": 0
 
 } */
struct Auto {
    var id: Int64?
    var registrationNumber: String?
    var model: String?
    var modelName: String?
    var group: String?
    var organization: String?
    var lastUpdate: Int64?
    var glonasId: Int64?
    
    init(){
        
    }
    init(json: JSON){
        self.id = json["id"].int64
        self.registrationNumber = json["registrationNumber"].string
        self.model = json["model"].string
        self.modelName = json["modelName"].string
        self.group = json["group"].string
        self.organization = json["organization"].string
        self.lastUpdate = json["lastUpdate"].int64
        self.glonasId = json["glonasId"].int64
    }
}