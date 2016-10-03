//
//  Filter.swift
//  Telemetry
//
//  Created by Agentum on 01.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit

class Filter: NSObject {
    
    var autoModelIds = [Int64]()
    var companyIds = [Int64]()
    
    var companyName: String?
    var registrationNumber: String?
    
    var filterDict: FilterDict?
    
    func filterIsSet() -> Bool{
        return (autoModelIds.count > 0 && companyIds.count > 0 && companyName?.characters.count > 0
                && registrationNumber?.characters.count > 0)
    }
}
