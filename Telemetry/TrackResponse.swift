//
//  TrackResponse.swift
//  Telemetry
//
//  Created by IMAC  on 10.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

//"status": "success",
//"track": [
//{
//"lat": 0,
//"lon": 0,
//"speed": 0,
//"azimut": 0,
//"time": 0
//}
//]
class TrackResponse: BaseResponse {

    var track: Track?
    
    override init(){
        super.init(_status: "Err", _reason: "Err")
    }
    
    override init(json: JSON){
        super.init(json: json)

        self.track = Track(json: json["track"])
        
    }

}
