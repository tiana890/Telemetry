//
//  BaseResponse.swift
//  Telemetry
//
//  Created by Agentum on 13.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON
import JASON

class BaseResponse: NSObject {

    var status: Status?
    var reason: String?
    
    init(_status: String?, _reason: String?) {
        super.init()
        
        self.status = Status(rawValue: _status ?? "error")
        self.reason = _reason
    }
    
    init(json: SwiftyJSON.JSON) {
        self.status = Status(rawValue: json["status"].string ?? "error")
        self.reason = json["reason"].string
    }
    
    init(json: JASON.JSON) {
        self.status = Status(rawValue: json["status"].string ?? "error")
        self.reason = json["reason"].string
    }
}
