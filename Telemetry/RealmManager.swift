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
        let autoObjects = realm.objects(AutoEntity.self)
        
        for(a) in autoObjects{
            ids.append(a.id)
        }
        return ids
    }
    
    static func getAutos() -> [Auto]{
        let realm = try! Realm()
        var autoModels = [Auto]()
//        let autoObjects = realm.objects(AutoJSON.self)
//        
//        for(a) in autoObjects{
//            let autoModel = Auto(json: JSON.parse(a.rawValue))
//            autoModels.append(autoModel)
//        }
        
        let autoObjects = realm.objects(AutoEntity.self)
        for a in autoObjects{
            let autoModel = Auto(entity: a)
            autoModels.append(autoModel)
        }
        return autoModels
    }
    
    static func getAutoById(_ id: Int) -> Auto?{
        
        let realm = try! Realm()
        if let a = realm.objects(AutoEntity.self).filter("id=\(id)").first{
            return Auto(entity: a)
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
                auto.regNumber = subJson["model"].string ?? ""
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
    
    //**********Types
    static func getFilterInfo() -> (autoTypes: [AutoModel], companies: [Company]){
        let realm = try! Realm()
        let autos = RealmManager.getAutos()
        let autosType = autos.map({ $0.type ?? "" })
        let set: Set<String> = Set<String>(autosType)
        
        let companies = autos.map({ Company(_id: $0.organizationId ?? 0, _name: $0.organization ?? "") })
        let companiesSet: Set<Company> = Set<Company>(companies)
        
        return (autoTypes: Array(set).map({ AutoModel(_name:$0) }).sorted(by: { $0.name!.lowercased() < $1.name!.lowercased() }), companies: Array(companiesSet).sorted(by: { $0.name!.lowercased() < $1.name!.lowercased() }))
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
        
        if PreferencesManager.showGarageNumber(), let garageNumber = filter.garageNumber, garageNumber != "" {
            numberExp = "garageNumber CONTAINS '\(garageNumber.uppercased())'"
        } else if !PreferencesManager.showGarageNumber(), let regNumber = filter.registrationNumber, regNumber != "" {
            numberExp = "regNumber CONTAINS '\(regNumber.uppercased())'"
        }
        
        let compExp =  "organizationId IN {" + filter.companyIds.map({ "\($0)" }).joined(separator: ",") + "}"
        let typeExp = "type IN {" + filter.types.map({"'\($0)'"}).joined(separator: ",") + "}"
        
        var commonExp = ""
        if filter.companyIds.count > 0 && filter.types.count > 0{
            commonExp = compExp + " AND " + typeExp
        } else if filter.types.count == 0 && filter.companyIds.count > 0{
            commonExp = compExp
        } else if filter.types.count > 0 && filter.companyIds.count == 0{
            commonExp = typeExp
        }
        let realm = try! Realm()
        
        if numberExp.characters.count > 0{
            if commonExp.characters.count > 0{
                return realm.objects(AutoEntity.self).filter(numberExp).filter(commonExp).map({ $0.id })
            } else {
                return realm.objects(AutoEntity.self).filter(numberExp).map({ $0.id })
            }
        } else {
            if commonExp.characters.count > 0{
                return realm.objects(AutoEntity.self).filter(commonExp).map({ $0.id })
            }
        }
        
        return []
        
        
    }
    
    static func getAutosWithFilter(filter: Filter) -> [Auto]{
        var numberExp = ""
        
        if PreferencesManager.showGarageNumber(), let garageNumber = filter.garageNumber, garageNumber != "" {
            numberExp = "garageNumber CONTAINS '\(garageNumber.uppercased())'"
        } else if !PreferencesManager.showGarageNumber(), let regNumber = filter.registrationNumber, regNumber != "" {
            numberExp = "regNumber CONTAINS '\(regNumber.uppercased())'"
        }
        
        let compExp =  "organizationId IN {" + filter.companyIds.map({ "\($0)" }).joined(separator: ",") + "}"
        let typeExp = "type IN {" + filter.types.map({"'\($0)'"}).joined(separator: ",") + "}"
        
        var commonExp = ""
        if filter.companyIds.count > 0 && filter.types.count > 0{
            commonExp = compExp + " AND " + typeExp
        } else if filter.types.count == 0 && filter.companyIds.count > 0{
            commonExp = compExp
        } else if filter.types.count > 0 && filter.companyIds.count == 0{
            commonExp = typeExp
        }
        
        let realm = try! Realm()
        
        if numberExp.characters.count > 0{
            if commonExp.characters.count > 0{
                return realm.objects(AutoEntity.self).filter(numberExp).filter(commonExp).map { Auto(entity: $0) }
            } else {
                return realm.objects(AutoEntity.self).filter(numberExp).map { Auto(entity: $0) }
            }
        } else {
            if commonExp.characters.count > 0{
                return realm.objects(AutoEntity.self).filter(commonExp).map { Auto(entity: $0) }
            }
        }
        
        return []
        
    }
    

    
}
