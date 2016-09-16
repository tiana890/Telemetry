//
//  AutoDetailResponse.swift
//  Telemetry
//
//  Created by IMAC  on 08.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

class AutoDetailResponse: BaseResponse {
    var autoDetail: AutoDetail?
    
    override init(json: JSON){
        super.init(json: json)
        
        self.autoDetail = AutoDetail(json: json["vehicle"])
    }
}

