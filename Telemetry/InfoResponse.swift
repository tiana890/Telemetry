//
//  InfoResponse.swift
//  Telemetry
//
//  Created by Пользователь on 19.10.16.
//  Copyright © 2016 GBU. All rights reserved.
//


import UIKit
import SwiftyJSON

class InfoResponse: BaseResponse {
    
    var url: String?
    
    override init(){
        super.init(_status: "Err", _reason: "Err")
    }
    
    override init(json: JSON){
        super.init(json: json)
        
        self.url = json["url"].string
        
    }
    
}

