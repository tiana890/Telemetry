//
//  Spot.swift
//  GBU
//
//  Created by Agentum on 18.04.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import Foundation
import GoogleMaps
import CoreLocation

class Spot: NSObject, GClusterItem{
    
    var position: CLLocationCoordinate2D
    var marker: GMSMarker
    
    init(_position: CLLocationCoordinate2D, _marker: GMSMarker) {
       self.position = _position
       self.marker = _marker
    }
}