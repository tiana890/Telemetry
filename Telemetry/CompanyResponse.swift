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
    /*
     {
     "code" : 200,
     "organization" : {
     "id" : 79,
     "user_senior_dispatcher_id" : 0,
     "phone" : "",
     "kpp" : "",
     "longitude" : 0,
     "short_name" : "ЕСМЕСМ\320Ц",
     "latitude" : 0,
     "max_work_hours" : 0,
     "position_responsible_waybill" : "",
     "motorcade_number" : "",
     "address" : "",
     "ogrn" : "",
     "stamp" : "",
     "auto_stocks" : 1,
     "inn" : "",
     "okpo" : "",
     "waybill_fill_type" : 0,
     "organization_parent_id" : 12,
     "name" : "ЕСМЦ"
     }
     */
    var company: Company?
    
    override init(json: JSON){
        super.init(json: json)
        
        self.company = Company(json: json["organization"])
        
    }
}
