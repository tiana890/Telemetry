//
//  AutoDetail.swift
//  Telemetry
//
//  Created by IMAC  on 08.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON
/*
***** old *********
 "speed" : 2.67,
 "glonassId" : 753,
 "id" : 447,
 "registrationNumber" : "Facere atque id et quos.",
 "model" : "Et velit ut qui.",
 "organization" : "Ut et fugit ducimus.",
 "type" : "Et ut cumque dicta.",
 "sensors" : [
     {
        "id" : 4,
        "name" : "Non alias dolor in voluptas."
     },
     {
        "id" : 2,
        "name" : "Dicta at optio est repellat."
     },
     {
        "id" : 3,
        "name" : "Vel impedit qui quaerat quas."
     },
     {
        "id" : 1,
        "name" : "Velit sit ab velit iure."
     },
     {
        "id" : 5,
        "name" : "Nihil nobis dolore maiores."
     }
 ]
 ******* new ******
 vid: 0,
 pid: 2,
 sid: 24909962,
 spe: "0",
 azm: 198,
 lat: "55.136364997629",
 lon: "37.443101582453",
 sta: "mv",
 dto: 1487349114,
 dtr: 1487349112,
 fue: ""[]"",
 parking: true,
 offline: false
 
 */

struct AutoDetail {
    var id: Int64?
    var registrationNumber: String?
    var model: String?
    var organization: String?
    var lastUpdate: Int64?
    var glonasId: Int64?
    var speed: Double?
    var type: String?
    var sensors: [Sensor]?
    
    init(){
        
    }
    init(json: JSON){
        print(json)
        self.id = json["id"].int64
        self.registrationNumber = json["registrationNumber"].string
        self.model = json["model"].string
        self.organization = json["organization"].string
        self.lastUpdate = json["lastUpdate"].int64
        self.glonasId = json["glonasId"].int64
        self.speed = json["speed"].double
        self.type = json["type"].string
        if let arr = json["sensors"].array{
            self.sensors = [Sensor]()
            for js in arr{
                self.sensors?.append(Sensor(json: js))
            }
        }
    }

}
