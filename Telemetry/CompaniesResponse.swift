//
//  CompaniesResponse.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

class CompaniesResponse: BaseResponse {
    
    var companies: [Company]?
    
    override init(json: JSON){
        super.init(json: json)
        if let dict = json["organizations"].dictionary{
            self.companies = [Company]()
            for(js) in dict.values{
                self.companies?.append(Company(json: js))
            }
        }
    }
}