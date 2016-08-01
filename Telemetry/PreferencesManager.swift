//
//  PreferencesManager.swift
//  Telemetry
//
//  Created by Agentum on 01.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import Foundation

class PreferencesManager: NSObject {
    
    static func saveToken(token: String){
        let def = NSUserDefaults.standardUserDefaults()
        def.setObject(token, forKey: "token")
        def.synchronize()
    }
    
    static func getToken() -> String?{
        let def = NSUserDefaults.standardUserDefaults()
        return def.objectForKey("token") as? String
    }
}
