//
//  VehiclesRequestSocket.swift
//  Telemetry
//
//  Created by Agentum on 08.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

class VehiclesRequestSocket{
    /*{"vehicles":"all","auth_token":"token_str", "bounds":[["lat","lon"],["lat","lon"]]} */
    
    var vehicles = [Int]()
    var bounds: (first:(lat: String, lon: String), second: (lat: String, lon: String))
    var token: String

    init(_token: String, _bounds: (first:(lat: String, lon: String), second: (lat: String, lon: String))){
        self.token = _token
        self.bounds = _bounds
    }
    
    
    func getData() -> Data?{
        var json: JSON?
       
        if(vehicles.count > 0){
            json = JSON(dictionaryLiteral: ("vehicles", "all"),
                            ("auth_token", token), ("bounds", [[0, 0],[180, 180]]), ("vehicles_id", vehicles))
        } else {
            json = JSON(dictionaryLiteral: ("vehicles", "all"),
                        ("auth_token", token), ("bounds", [[0, 0],[180, 180]]))
        }
        print(json)
        return try! json!.rawData()
    }
}
