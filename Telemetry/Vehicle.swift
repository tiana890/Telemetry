//
//  Vehicle.swift
//  Telemetry
//
//  Created by Agentum on 08.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit

class Vehicle: NSObject {
    var id: Int64?
    
    init(_id: Int64){
        super.init()
        
        self.id = _id
    }
}
