//
//  AutoModel.swift
//  Telemetry
//
//  Created by IMAC  on 04.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//


import UIKit
import SwiftyJSON


struct AutoModel {
    var id: Int?
    var name: String?
    
    init(){
        
    }
    
    init(json: JSON){
        self.id = json["id"].int
        self.name = json["name"].string
       
    }
}
