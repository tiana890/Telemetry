//
//  FilterDict.swift
//  Telemetry
//
//  Created by IMAC  on 04.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON


struct FilterDict {
    
    var companies: [Company]?
    var models: [AutoModel]?

    
    init(){
        
    }

    init(json: JSON){
        
        if let modelsArray = json["models"].array{
            self.models = [AutoModel]()
            for js in modelsArray{
                self.models?.append(AutoModel(json: js))
            }
        }
        
        if let companiesArray = json["organizations"].array{
            self.companies = [Company]()
            for js in companiesArray{
                self.companies?.append(Company(json: js))
            }
        }

    }
}
