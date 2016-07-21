//
//  POIItem.swift
//  Telemetry
//
//  Created by Agentum on 20.07.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import GoogleMaps
import UIKit

class POIItem: NSObject, GMUClusterItem {
    
    var position: CLLocationCoordinate2D
    var name: String!
    
    init(position: CLLocationCoordinate2D, name: String) {
        self.position = position
        self.name = name
    }
}
