//
//  AutoJSON.swift
//  Telemetry
//
//  Created by IMAC  on 02.10.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import RealmSwift

class AutoJSON: Object {
    dynamic var id = 0
    dynamic var rawValue = ""
    
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
