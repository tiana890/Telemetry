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
/*
{
    tracks: {
        4662: [
        {
            prk: 1,
            off: 0,
                fuel_data: {
                2: "161.265"
                },
                evt: {
                id: 0,
                name: "Таймер (зажигание вкл)"
                },
                spe: "0",
                lat: "55.769438179156",
                lon: "37.519709872436",
                azm: 254,
                sid: 132134,
                sta: "mv",
                dto: 1486050820,
                dtr: 1486253421,
                date_flush: 1486253522
            }
        ]
    }
}*/

struct TrackItem{
    var lat: Double?
    var lon: Double?
    var speed: Int64?
    var azimut: Int?
    var time: Int64?
    
    init(json: JSON){
        self.lat = json["lat"].double
        self.lon = json["lon"].double
        self.speed = json["spe"].int64
        self.azimut = json["azm"].int
        self.time = json["dto"].int64
    }
}

class Track: NSObject {
    
    var trackArray: [TrackItem]?
    
    override init(){
        super.init()
    }
    
    init(json: JSON){
        super.init()
        
        self.trackArray = []
        for(js) in json.arrayValue{
            self.trackArray?.append(TrackItem(json: js))
            
        }
    }
    
}
