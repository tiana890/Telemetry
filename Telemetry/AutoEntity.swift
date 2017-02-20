//
//  AutoEntity.swift
//  Telemetry
//
//  Created by IMAC  on 25.09.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import RealmSwift

class AutoEntity: Object {
    /*
     var id: Int64?
     var registrationNumber: String?
     var model: String?
     var organization: String?
     var lastUpdate: Int64?
     var speed: Double?
     var type: String?
     */
    
    dynamic var id = 0
    dynamic var regNumber = ""
    dynamic var model = ""
    dynamic var organization = ""
    dynamic var organizationId = 0
    dynamic var type = ""
    dynamic var garageNumber = ""
    dynamic var lastUpdate = ""
    dynamic var speed = 0
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
