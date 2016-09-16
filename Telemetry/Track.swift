//
//  Track.swift
//  Telemetry
//
//  Created by IMAC  on 10.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

/*
 {
     "status": "success",
     "track": [
         {
             "lat": 0,
             "lon": 0,
             "speed": 0,
             "azimut": 0,
             "time": 0
         }
     ]
 }

 */

struct TrackItem{
    var lat: Double?
    var lon: Double?
    var speed: Int64?
    var azimut: Int?
    var time: Int64?
    
    init(json: JSON){
        self.lat = json["lat"].double
        self.lon = json["lon"].double
        self.speed = json["speed"].int64
        self.azimut = json["azimut"].int
        self.time = json["time"].int64
    }
}

class Track: NSObject {
    
    var trackArray: [TrackItem]?
    
    override init(){
        super.init()
    }
    
    init(json: JSON){
        super.init()
        
        if let arr = json.array{
            self.trackArray = []
            for js in arr{
                self.trackArray?.append(TrackItem(json: js))
            }
        }
    }
    
}
