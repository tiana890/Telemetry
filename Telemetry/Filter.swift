//
//  Filter.swift
//  Telemetry
//
//  Created by Agentum on 01.08.16.
//  Copyright © 2016 GBU. All rights reserved.
//

import UIKit
import SwiftyJSON

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class Filter: NSObject {
    
    var autoModelIds = [Int]()
    var companyIds = [Int]()
    
    var companyName: String?
    var registrationNumber: String?
    
    var garageNumber: String?
    
    var filterDict: FilterDict?
    
    func filterIsSet() -> Bool{
        let numberString = PreferencesManager.showGarageNumber() ? garageNumber : registrationNumber
        return (autoModelIds.count > 0 || companyIds.count > 0 || companyName?.characters.count > 0
                || numberString?.characters.count > 0)
    }
    
    func isEqualToFilter(_ filter: Filter?) -> Bool {
        if let f = filter{
            if(autoModelIds.elementsEqual(f.autoModelIds, by: {
                return ($0 == $1) ? true : false
            })){
                if(companyIds.elementsEqual(f.companyIds, by: {
                    return ($0 == $1) ? true : false
                })){
                    if(!PreferencesManager.showGarageNumber()){
                        if(registrationNumber == f.registrationNumber){
                            return true
                        }
                    } else {
                        if(garageNumber == f.garageNumber){
                            return true
                        }

                    }
                }
            }
        }
        return false
    }
    
    static func createCopy(_ filter: Filter?) -> Filter?{
        if(filter != nil){
            let f = Filter()
            f.autoModelIds = [Int]()
            f.companyIds = [Int]()
            
            f.autoModelIds.append(contentsOf: filter!.autoModelIds)
            f.companyIds.append(contentsOf: filter!.companyIds)
            
            if(filter!.companyName != nil){
                f.companyName = String(validatingUTF8: filter!.companyName!)
            }
            
            if(filter!.registrationNumber != nil){
                f.registrationNumber = String(validatingUTF8: filter!.registrationNumber!)
            }
            
            if(filter!.garageNumber != nil){
                f.garageNumber = String(validatingUTF8: filter!.garageNumber!)
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

        dict["modelIds"] = autoModelIds as AnyObject?
        dict["organizationIds"] = companyIds as AnyObject?
        
        dict["registrationNumber"] = self.registrationNumber as AnyObject?? ?? "" as AnyObject?
        dict["garageNumber"] = self.garageNumber as AnyObject?? ?? "" as AnyObject?
        
        
        var dat = Data()
        do{
            try dat = JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            if let jsonString = NSString.init(data: dat, encoding: String.Encoding.utf8.rawValue){
                return jsonString as String
            }
            
        } catch {
            return ""
        }
        return ""
    }

}
