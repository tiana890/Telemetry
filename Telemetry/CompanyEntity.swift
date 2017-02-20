//
//  CompanyEntity.swift
//  Telemetry
//
//  Created by Пользователь on 19.02.17.
//  Copyright © 2017 GBU. All rights reserved.
//

import RealmSwift

class CompanyEntity: Object {
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
    dynamic var name = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
