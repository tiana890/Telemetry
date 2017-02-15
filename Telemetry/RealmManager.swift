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

    static func saveAuto(_ autoModel: Auto){
        let autoEntity = AutoEntity()
        
        autoEntity.id = Int(autoModel.id ?? 0)
        autoEntity.regNumber = autoModel.registrationNumber ?? ""
        autoEntity.model = autoModel.model ?? ""
        autoEntity.organization = autoModel.organization ?? ""
        autoEntity.type = autoModel.type ?? ""
        autoEntity.garageNumber = autoModel.garageNumber ?? ""
        
        let realm = try! Realm()
        
        try! realm.write() {
            realm.add(autoEntity, update: true)
        }
    }
    
    static func getAutoIds() -> [Int]{
        let realm = try! Realm()
        
        var ids = [Int]()
        let autoObjects = realm.objects(AutoJSON.self)
        
        for(a) in autoObjects{
            ids.append(a.id)
        }
        return ids
    }
    
    static func getAutos() -> [Auto]{
        let realm = try! Realm()
        
        var autoModels = [Auto]()
        let autoObjects = realm.objects(AutoJSON.self)
        
        for(a) in autoObjects{
            let autoModel = Auto(json: JSON.parse(a.rawValue))
            autoModels.append(autoModel)
        }
        
        return autoModels
    }
    
    static func getAutoById(_ id: Int) -> Auto?{
        
        let realm = try! Realm()
        let autosJSON = realm.objects(AutoJSON.self).filter("id=\(id)")
        if autosJSON.count > 0{
            let autoJSON = autosJSON[0]
            let json = JSON.parse(autoJSON.rawValue)
            let auto = Auto(json: json)
            return auto
        }
        
        return nil
    }
    
    static func saveAutoJSONDict(_ dict: JSON) -> [Int]{
        let realm = try! Realm()
        var arr = [AutoJSON]()
        
        var ids = [Int]()

        for (key,subJson):(String, SwiftyJSON.JSON) in dict.dictionaryValue {
            if let key = Int(key){
                ids.append(key)
                let autoJSON = AutoJSON()
                autoJSON.id = key
                autoJSON.rawValue = subJson.rawString() ?? ""
                arr.append(autoJSON)
            }
        }
        try! realm.write() {
            realm.add(arr, update: true)
        }
        return ids
    }
    
//    static func getAutoIDsWithModelIds(modelIds: [Int], organizations: [String]) -> [Int]{
//        let realm = try! Realm()
//        
//        var autoModels = [Auto]()
//        
//        let predicate = NSPredicate(format: "", argumentArray: <#T##[AnyObject]?#>)
//        let autosJSON = realm.objects(AutoJSON).filter("rawValue")
//        
//        for(a) in autoObjects{
//            let autoModel = Auto(json: JSON.parse(a.rawValue))
//            autoModels.append(autoModel)
//        }
//        
//        return autoModels
//    }

}
