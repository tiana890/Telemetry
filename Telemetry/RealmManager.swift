//
//  RealmManager.swift
//  Telemetry
//
//  Created by IMAC  on 21.09.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import RealmSwift

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
}
