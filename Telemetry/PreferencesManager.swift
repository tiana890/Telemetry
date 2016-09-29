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
    
    static func deleteToken(){
        let def = NSUserDefaults.standardUserDefaults()
        def.removeObjectForKey("token")
    }
    
    static func setAutosLoaded(ifLoaded: Bool) {
        let def = NSUserDefaults.standardUserDefaults()
        def.setBool(ifLoaded, forKey: "ifAutosLoaded")
        def.synchronize()
    }
    
    static func ifAutosLoaded() -> Bool{
        let def = NSUserDefaults.standardUserDefaults()
        return def.boolForKey("ifAutosLoaded")
    }
}
