//
//  NSDate+dateFromFormat.swift
//  GBU
//
//  Created by IMAC  on 26.12.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit

extension NSDate
{
    convenience
    init(dateString:String) {
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:d)
    }
    
    convenience init(dateString: String, formatString: String){
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = formatString
        dateStringFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        let d = dateStringFormatter.dateFromString(dateString)!
        self.init(timeInterval:0, sinceDate:d)
        
    }
    
    func toString() -> String
    {
        //Get Short Time String
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMM HH:mm"
        let str = formatter.stringFromDate(self)
        
        //Return Short Time String
        return str
    }
    
    func toPickerString() -> String
    {
        //Get Short Time String
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        let str = formatter.stringFromDate(self)
        
        //Return Short Time String
        return str
    }
    
    func toPickerStringWithTime() -> String
    {
        //Get Short Time String
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        let str = formatter.stringFromDate(self)
        
        //Return Short Time String
        return str
    }
    
    func toStringWithFormat(format: String) -> String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        let str = formatter.stringFromDate(self)
        
        //Return Short Time String
        return str
    }
    
    func toFileName() -> String
    {
        //Get Short Time String
        let formatter = NSDateFormatter()
        formatter.dateFormat = "_yyyy_MM_dd_HH_mm_ss"
        let str = formatter.stringFromDate(self)
        
        //Return Short T
        return str
    }
    
    func day() -> Int
    {
        //Get Hour
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: self)
        let day = components.day
        
        //Return Hour
        return day
    }
    
    
    func hour() -> Int
    {
        //Get Hour
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Hour, fromDate: self)
        let hour = components.hour
        
        //Return Hour
        return hour
    }
    
    
    func minute() -> Int
    {
        //Get Minute
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Minute, fromDate: self)
        let minute = components.minute
        
        //Return Minute
        return minute
    }
    
}
