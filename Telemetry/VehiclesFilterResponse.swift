//
//  VehiclesFilterResponse.swift
//  Telemetry
//
//  Created by IMAC  on 04.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

class VehiclesFilterResponse: BaseResponse {

    var filterDict: FilterDict?
    
    override init() {
        super.init(_status: Status.Success.rawValue, _reason: nil)
        filterDict = FilterDict()
    }
    
    override init(json: JSON){
        super.init(json: json)
        
        self.filterDict = FilterDict(json: json["data"])
        
    }
}
