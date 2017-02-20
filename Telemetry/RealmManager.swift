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

    //********Destroy db
    static func setConfiguration(){
        //let realm = try! Realm()
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
    }
    //********Autos
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
//        let realm = try! Realm()
//        var arr = [AutoJSON]()
//        
//        var ids = [Int]()
//
//        for (key,subJson):(String, SwiftyJSON.JSON) in dict.dictionaryValue {
//            if let key = Int(key){
//                ids.append(key)
//                let autoJSON = AutoJSON()
//                autoJSON.id = key
//                autoJSON.rawValue = subJson.rawString() ?? ""
//                arr.append(autoJSON)
//            }
//        }
//        try! realm.write() {
//            realm.add(arr, update: true)
//        }
//        return ids
        let realm = try! Realm()
        var arr = [AutoEntity]()
        
        var ids = [Int]()
        
        for (key,subJson):(String, SwiftyJSON.JSON) in dict.dictionaryValue {
            if let key = Int(key){
                ids.append(key)
                let auto = AutoEntity()
                /*
                 {
                 
                 id: 399,
                 model: "К060КА777",
                 type: "Аварийно-техническая",
                 garage_number: "",
                 speed: 0,
                 lastUpdate: 0,
                 organization_id: 95,
                 organization: "АО "Мосводоканал"
                 
                 } */
                auto.id = subJson["id"].int ?? 0
                auto.model = subJson["model"].string ?? ""
                auto.type = subJson["type"].string ?? ""
                auto.garageNumber = subJson["garage_number"].string ?? ""
                auto.speed = subJson["speed"].int ?? 0
                auto.lastUpdate = subJson["lastUpdate"].string ?? ""
                auto.organizationId = subJson["organization_id"].int ?? 0
                auto.organization = subJson["organization"].string ?? ""
                arr.append(auto)
            }
        }
        try! realm.write() {
            realm.add(arr, update: true)
        }
        return ids
    }
    //**********Companies
    static func saveCompanies(_ companies:[Company]) {
        let realm = try! Realm()
       
        var companyEntities: [CompanyEntity] = []
        for c in companies{
            let entity = CompanyEntity()
            entity.id = c.id ?? 0
            entity.name = c.name ?? ""
            companyEntities.append(entity)
        }
        try! realm.write() {
            realm.add(companyEntities, update: true)
        }
    }
    
    static func getCompanies() -> [Company]{
        let realm = try! Realm()
        return realm.objects(CompanyEntity.self).map { return Company(_id: $0.id, _name: $0.name) }
    }
    
    static func testInfo(){
        let realm = try! Realm()
        let c = CompanyEntity()
        c.id = 142
        c.name = "org 1"
        
        let c2 = CompanyEntity()
        c2.id = 96
        c2.name = "wefwerg"
        try! realm.write() {
            realm.add([c, c2], update: true)
        }
    }
    
    static func getAutoIdsWithFilter(filter: Filter) -> [Int]{
        var numberExp = ""

        if PreferencesManager.showGarageNumber(), filter.garageNumber != nil{
            numberExp = "rawValue LIKE '\"garage_number\" : \"*\(filter.garageNumber!)*\""
        } else if filter.registrationNumber != nil, !PreferencesManager.showGarageNumber(){
            numberExp = "rawValue LIKE '\"model\" : \"*\(filter.registrationNumber!)*\""
        }
//        {
//            "lastUpdate" : 0,
//            "organization" : "ГБУ Жилищник района Филевский парк",
//            "id" : 12973,
//            "garage_number" : "",
//            "speed" : 0,
//            "model" : "77НВ6837",
//            "type" : null,
//            "organization_id" : 147
//        }
        
        var compExp = filter.companyIds.map({ "rawValue CONTAINS '\"organization_id\" : \($0)'" }).joined(separator: " OR ")
        let realm = try! Realm()
        return realm.objects(AutoJSON.self).filter(compExp).map { return $0.id }
        
    }
    
    static func getAutosWithFilter(filter: Filter) -> [Auto]{
        var numberExp = ""
        
//        if PreferencesManager.showGarageNumber(), filter.garageNumber != nil{
//            numberExp = "rawValue LIKE '\"garage_number\" : \"*\(filter.garageNumber!)*\""
//        } else if filter.registrationNumber != nil, !PreferencesManager.showGarageNumber(){
//            numberExp = "rawValue BEGINSWITH '\"model\" : \"\(filter.registrationNumber!)' OR rawValue ENDSWITH '\"model\" : \"\(filter.registrationNumber!)\"
//        }
        //        {
        //            "lastUpdate" : 0,
        //            "organization" : "ГБУ Жилищник района Филевский парк",
        //            "id" : 12973,
        //            "garage_number" : "",
        //            "speed" : 0,
        //            "model" : "77НВ6837",
        //            "type" : null,
        //            "organization_id" : 147
        //        }
        
        var compExp = filter.companyIds.map({ "rawValue CONTAINS '\"organization_id\" : \($0)'" }).joined(separator: " AND ")
        let realm = try! Realm()
        return realm.objects(AutoJSON.self).filter(compExp).map { return Auto(json:JSON.parse($0.rawValue)) }
    }
    

    
}
