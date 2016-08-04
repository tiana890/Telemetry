//
//  Filter.swift
//  Telemetry
//
//  Created by Agentum on 01.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit

class Filter: NSObject {
    
    var modelIds = [Int]()
    var companyIds = [Int]()
    
    var companyName: String?
    var registrationNumber: String?
    
    var filterDict: FilterDict?
}
