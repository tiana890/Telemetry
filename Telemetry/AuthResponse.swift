//
//  AuthResponse.swift
//  Telemetry
//
//  Created by Agentum on 13.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

class AuthResponse: BaseResponse {

    var token: String?
    
    override init() {
        super.init()
    }
    override init(json: JSON){
        super.init(json: json)
        
        self.token = json["user"]["token"].string
    }
}
