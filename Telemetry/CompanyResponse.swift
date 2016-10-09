//
//  CompanyResponse.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

class CompanyResponse: BaseResponse {
    var company: Company?
    
    override init(json: JSON){
        super.init(json: json)
        
        self.company = Company()
        self.company?.id = json["organization"]["id"].int
        self.company?.name = json["organization"]["name"].string
    }
}
