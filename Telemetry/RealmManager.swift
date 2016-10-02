//
//  RealmManager.swift
//  Telemetry
//
//  Created by IMAC  on 21.09.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import RealmSwift
import SwiftyJSON

class RealmManager: NSObject {

    static func saveAuto(autoModel: Auto){
        let autoEntity = AutoEntity()
        
        autoEntity.id = Int(autoModel.id ?? 0)
        autoEntity.regNumber = autoModel.registrationNumber ?? ""
        autoEntity.model = autoModel.model ?? ""
        autoEntity.organization = autoModel.organization ?? ""
        autoEntity.type = autoModel.type ?? ""
        
        let realm = try! Realm()
        
        try! realm.write() {
            realm.add(autoEntity, update: true)
        }
    }
    
    static func getAutos() -> [Int:Auto]{
        let realm = try! Realm()
        
        var autoModels = [Int:Auto]()
        let autoObjects = realm.objects(AutoEntity)
        
        for(a) in autoObjects{
            var autoModel = Auto()
            autoModel.id = a.id
            autoModel.registrationNumber = a.regNumber
            autoModel.model = a.model
            autoModel.organization = a.organization
            autoModel.type = a.type
            autoModels[a.id] = autoModel
        }
        
        return autoModels
    }
    
    static func getAutoById(id: Int) -> Auto?{
        
        let realm = try! Realm()
        let autosJSON = realm.objects(AutoJSON).filter("id=\(id)")
        if autosJSON.count > 0{
            let autoJSON = autosJSON[0]
            let json = JSON.parse(autoJSON.rawValue)
            let auto = Auto(json: json)
            return auto
        }
        
        return nil
    }
    
    static func saveAutoJSONDict(dict: JSON){
        let realm = try! Realm()
        var arr = [AutoJSON]()
        for (key,subJson):(String, SwiftyJSON.JSON) in dict {
            if let key = Int(key){
                let autoJSON = AutoJSON()
                autoJSON.id = key
                autoJSON.rawValue = subJson.rawString() ?? ""
                arr.append(autoJSON)
            }
        }
        try! realm.write() {
            realm.add(arr, update: true)
        }
    }
    
    

}
