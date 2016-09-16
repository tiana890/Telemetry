//
//  AutosResponse.swift
//  Telemetry
//
//  Created by IMAC  on 28.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

//    {
//        "status": "success",
//        "vehicles": {
//            "12": {
//                "id": 0,
//                "registrationNumber": "string",
//                "model": "string",
//                "modelName": "string",
//                "group": "string",
//                "organization": "string",
//                "lastUpdate": 0
//            }
//        }
//    }


class AutosResponse: BaseResponse {
    var autos: [Auto]?
    override init(json: JSON){
        super.init(json: json)
        if let dict = json["vehicles"].dictionary{
            self.autos = [Auto]()
            for(js) in dict.values{
                self.autos?.append(Auto(json: js))
            }
        }
    }
}
