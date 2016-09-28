//
//  GMSMapView+Bounds.swift
//  Telemetry
//
//  Created by IMAC  on 28.09.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import GoogleMaps

extension GMSMapView {

    func getBounds() -> (first:(lat: String, lon: String), second: (lat: String, lon: String)){

        
        let visibleRegion = self.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(region: visibleRegion)
        let northEast = bounds.northEast
        let southWest = bounds.southWest
            
        return (first: (lat:"\(southWest.latitude)", lon: "\(southWest.longitude)"), second: (lat:"\(northEast.latitude)", lon: "\(northEast.longitude)"))
    }
}
