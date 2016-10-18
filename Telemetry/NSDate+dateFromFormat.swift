//
//  NSDate+dateFromFormat.swift
//  GBU
//
//  Created by IMAC  on 26.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit

extension Date
{
    
    init(dateString:String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:d)
    }
    
    init(dateString: String, formatString: String){
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = formatString
        dateStringFormatter.locale = Locale(identifier: "en_US_POSIX")
        let d = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval:0, since:d)
        
    }
    
    func toString() -> String
    {
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM HH:mm"
        let str = formatter.string(from: self)
        
        //Return Short Time String
        return str
    }
    
    func toPickerString() -> String
    {
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        let str = formatter.string(from: self)
        
        //Return Short Time String
        return str
    }
    
    func toPickerStringWithTime() -> String
    {
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        let str = formatter.string(from: self)
        
        //Return Short Time String
        return str
    }
    
    func toRussianString() -> String{
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm dd.MM.yyyy"
        let str = formatter.string(from: self)
        
        //Return Short Time String
        return str
    }
    
    func toStringWithFormat(_ format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        let str = formatter.string(from: self)
        
        //Return Short Time String
        return str
    }
    
    func toFileName() -> String
    {
        //Get Short Time String
        let formatter = DateFormatter()
        formatter.dateFormat = "_yyyy_MM_dd_HH_mm_ss"
        let str = formatter.string(from: self)
        
        //Return Short T
        return str
    }
    
    func day() -> Int
    {
        //Get Hour
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.hour, from: self)
        let day = components.day
        
        //Return Hour
        return day!
    }
    
    
    func hour() -> Int
    {
        //Get Hour
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.hour, from: self)
        let hour = components.hour
        
        //Return Hour
        return hour!
    }
    
    
    func minute() -> Int
    {
        //Get Minute
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.minute, from: self)
        let minute = components.minute
        
        //Return Minute
        return minute!
    }
    
}
