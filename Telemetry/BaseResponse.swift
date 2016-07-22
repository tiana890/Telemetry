//
//  BaseResponse.swift
//  Telemetry
//
//  Created by Agentum on 13.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

class BaseResponse: NSObject {

    var status: String?
    var reason: String?
    
    init(_status: String?, _reason: String?) {
        super.init()
        
        self.status = _status
        self.reason = _reason
    }
    
    init(json: JSON) {
        self.status = json["status"].string
        self.reason = json["reason"].string
    }
}