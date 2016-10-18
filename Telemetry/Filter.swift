//
//  Filter.swift
//  Telemetry
//
//  Created by Agentum on 01.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

class Filter: NSObject {
    
    var autoModelIds = [Int]()
    var companyIds = [Int]()
    
    var companyName: String?
    var registrationNumber: String?
    
    var filterDict: FilterDict?
    
    func filterIsSet() -> Bool{
        return (autoModelIds.count > 0 || companyIds.count > 0 || companyName?.characters.count > 0
                || registrationNumber?.characters.count > 0)
    }
    
    func isEqualToFilter(filter: Filter?) -> Bool {
        if let f = filter{
            if(autoModelIds.elementsEqual(f.autoModelIds, isEquivalent: {
                return ($0 == $1) ? true : false
            })){
                if(companyIds.elementsEqual(f.companyIds, isEquivalent: {
                    return ($0 == $1) ? true : false
                })){
                    if(registrationNumber == f.registrationNumber){
                        return true
                    }
                }
            }
        }
        return false
    }
    
    static func createCopy(filter: Filter?) -> Filter?{
        if(filter != nil){
            let f = Filter()
            f.autoModelIds = [Int]()
            f.companyIds = [Int]()
            
            f.autoModelIds.appendContentsOf(filter!.autoModelIds)
            f.companyIds.appendContentsOf(filter!.companyIds)
            
            if(filter!.companyName != nil){
                f.companyName = String(UTF8String: filter!.companyName!)
            }
            
            if(filter!.registrationNumber != nil){
                f.registrationNumber = String(UTF8String: filter!.registrationNumber!)
            }
            return f
        }
        return nil
    }
    
    /*
     func getJSONString() -> NSString{
     var dict = [String: String]()
     dict["login"] = self.log ?? ""
     dict["pass"] = self.pass?.md5 ?? ""
     //["login": "admin", "pass": "202cb962ac59075b964b07152d234b70"]
     
     var dat = NSData()
     do{
     try dat = NSJSONSerialization.dataWithJSONObject(dict, options: .PrettyPrinted)
     if let jsonString = NSString.init(data: dat, encoding: NSUTF8StringEncoding){
     
     return jsonString
     }
     
     } catch {
     return ""
     }
     return ""
     }

     */
    
    func getJSONString() -> String?{
        
        var dict = [String: AnyObject]()
        //dict["token"] = PreferencesManager.getToken() ?? ""
        dict["modelIds"] = autoModelIds
        dict["organizationIds"] = companyIds
        
        if(!PreferencesManager.showGarageNumber()){
            dict["registrationNumber"] = self.registrationNumber ?? ""
        } else {
            dict["garageNumber"] = self.registrationNumber ?? ""
        }
        
        print(dict)
        var dat = NSData()
        do{
            try dat = NSJSONSerialization.dataWithJSONObject(dict, options: .PrettyPrinted)
            if let jsonString = NSString.init(data: dat, encoding: NSUTF8StringEncoding){
                print(jsonString)
                return jsonString as String
            }
            
        } catch {
            return ""
        }
        return ""
    }

}
