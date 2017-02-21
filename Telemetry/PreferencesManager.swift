//
//  PreferencesManager.swift
//  Telemetry
//
//  Created by Agentum on 01.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import Foundation
import SwiftyJSON

class PreferencesManager: NSObject {
    
    static func saveWasUpdated(value: Bool){
        let def = UserDefaults.standard
        def.set(value, forKey: "wasUpdated")
        def.synchronize()
    }
    
    static func getWasUpdated() -> Bool{
        let def = UserDefaults.standard
        return def.bool(forKey: "wasUpdated")
    }
    
    static func saveToken(_ token: String){
        let def = UserDefaults.standard
        def.set(token, forKey: "token")
        def.synchronize()
    }
    
    static func getToken() -> String?{
        let def = UserDefaults.standard
        return def.object(forKey: "token") as? String
    }
    
    static func deleteToken(){
        let def = UserDefaults.standard
        def.removeObject(forKey: "token")
    }
    
    static func setAutosLoaded(_ ifLoaded: Bool) {
        let def = UserDefaults.standard
        def.set(ifLoaded, forKey: "ifAutosLoaded")
        def.synchronize()
    }
    
    static func ifAutosLoaded() -> Bool{
        let def = UserDefaults.standard
        return def.bool(forKey: "ifAutosLoaded")
    }
    
    static func showGarageNumber() -> Bool{
        let def = UserDefaults.standard
        return def.bool(forKey: "showStateNumber")
    }
    
    static func setShowGarageNumber(_ value: Bool){
        let def = UserDefaults.standard
        def.set(value, forKey: "showStateNumber")
        def.synchronize()
    }
    
    static func saveServer(_ server: String){
        let def = UserDefaults.standard
        def.set(server, forKey: "server")
        def.synchronize()
    }
    
    static func getServer() -> String{
        let def = UserDefaults.standard
        return def.string(forKey: "server") ?? ""
    }
    
    static func saveAPIServer(_ apiServer: String){
        let def = UserDefaults.standard
        def.set(apiServer, forKey: "apiServer")
        def.synchronize()
    }
    
    static func getAPIServer() -> String{
        let def = UserDefaults.standard
        return def.string(forKey: "apiServer") ?? ""
    }
}
