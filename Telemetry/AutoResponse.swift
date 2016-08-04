//
//  AutoResponse.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

class AutoResponse: BaseResponse {
    var auto: Auto?
    
    override init(json: JSON){
        super.init(json: json)
        
        self.auto = Auto(json: json["vehicle"])
    }
}
