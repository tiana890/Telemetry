//
//  AutosDictResponse.swift
//  Telemetry
//
//  Created by IMAC  on 04.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON
import JASON

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


class AutosDictResponse: BaseResponse {
    var autosDict: [Int:Auto]?
    
    
    override init(){
        super.init()
    }
    
    override init(json: SwiftyJSON.JSON){
        super.init(json: json)
        if let dict = json["vehicles"].dictionary{
            self.autosDict = [Int:Auto]()
            for(js) in dict.values{
                let auto = Auto(json: js)
                if let autoId = auto.id{
                    self.autosDict![autoId] = auto
                }
            }
        }
    }
    
    override init(json: JASON.JSON){
        super.init(json: json)
        if let dict = json["vehicles"].jsonDictionary{
            self.autosDict = [Int:Auto]()
            for(js) in dict.values{
                let auto = Auto(json: js)
                if let autoId = auto.id{
                    self.autosDict![autoId] = auto
                }
            }
        }
    }
    
}
