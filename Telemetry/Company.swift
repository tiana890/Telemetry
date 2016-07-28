//
//  Organization.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

struct Company {
    var id: Int64?
    var name: String?
    
    init(){
        
    }
    init(json: JSON){
        self.id = json["id"].int64
        self.name = json["name"].string
    }
}
