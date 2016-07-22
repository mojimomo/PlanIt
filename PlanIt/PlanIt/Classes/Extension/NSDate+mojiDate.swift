//
//  NSDate+mojiDate.swift
//  PlanIt
//
//  Created by Ken on 16/7/2.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation

extension NSDate{
    ///计算此时间和结束百分比
    func percentFromCurrentTime(endDate: NSDate) -> Double{
        let timeEnd = endDate.timeIntervalSince1970
        let timeBegin = self.timeIntervalSince1970
        let currentDate = NSDate()
        let timecurrent = currentDate.timeIntervalSince1970
        let percent = (timecurrent - timeBegin)/(timeEnd - timeBegin)
        return percent
    }
    
    ///计算此时间与结束时间相差几天
    func daysToEndDate(endDate: NSDate) -> Int{
        let timeEnd = endDate.timeIntervalSince1970
        let timeBegin = self.timeIntervalSince1970
        let days = (timeEnd - timeBegin)/( 60 * 60 * 24)
        return Int(days)
    }
    
    ///计算此时间与结束时间相差几月
    func monthsToEndDate(endDate: NSDate) -> Int{
        let timeEnd = endDate.timeIntervalSince1970
        let timeBegin = self.timeIntervalSince1970
        let months = (timeEnd - timeBegin)/( 60 * 60 * 24 * 30)
        return Int(months)
    }
    
    ///与现在时间比较
    func compareCurrentTime() -> String{
        var timeInterval = self.timeIntervalSinceNow
        var result = ""
        var tmp = 0
        
        //判断是否是负
        if timeInterval < 0{
            timeInterval = -timeInterval
        }
        
        //判断时间
        if timeInterval < 60{
            result += "1 分"
        }else if timeInterval / 60 < 60 {
            tmp = Int(timeInterval / 60 )
            result += "\(tmp) 分"
        }else if timeInterval / 60 / 60 < 24 {
            tmp = Int(timeInterval / 60 / 24)
            result += "\(tmp) 小时"
        }else if timeInterval / 60 / 60 / 24 < 30 {
            tmp = Int(timeInterval / 60 / 60 / 24 )
            result += "\(tmp) 天"
        }else if timeInterval / 60 / 60 / 24 / 30 < 12 {
            tmp = Int(timeInterval / 60 / 60 / 24 / 30 )
            result += "\(tmp) 月"
        }else{
            tmp = Int(timeInterval / 60 / 60 / 24 / 30 / 12)
            result += "\(tmp) 年"
        }
        return result
    }
    
    ///增加一天
    func increase1Day() -> NSDate? {
        let dateComponents = NSDateComponents()
        dateComponents.day = 1
        let nextDate = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: self, options: NSCalendarOptions.init(rawValue: 0))
        return nextDate
        
    }
    
    ///增加几天
    func increaseDays(day: Int) -> NSDate? {
        let dateComponents = NSDateComponents()
        dateComponents.day = day
        let nextDate = NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: self, options: NSCalendarOptions.init(rawValue: 0))
        return nextDate
        
    }
    
    ///格式化日期到字符串 YYYY年MM月DD日
    func FormatToStringYYYYMMDD() -> String{
        let dateFormat = NSDateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("yyyy-MM-dd")
        dateFormat.locale = NSLocale(localeIdentifier: "zh_CN")
        dateFormat.dateStyle = .LongStyle
        let strDate = dateFormat.stringFromDate(self)
        return strDate
    }
    
    ///格式化日期到字符串 MM月DD日
    func FormatToStringMMMMDD() -> String{
        let dateFormat = NSDateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("MMMMdd")
        dateFormat.locale = NSLocale(localeIdentifier: "zh_CN")
        let strDate = dateFormat.stringFromDate(self)
        return strDate
    }
    
    ///格式化日期到字符串 YYYY年MM月DD日HH小时MM分钟
    func FormatToStringYYYYMMMMDDHHMM() -> String{
        let dateFormat = NSDateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMMddhhmm")
        dateFormat.locale = NSLocale(localeIdentifier: "zh_CN")
        let strDate = dateFormat.stringFromDate(self)
        return strDate
    }
    
    ///格式化日期到字符串 YYYY年MM月DD日HH小时MM分钟ss秒
    func FormatToStringYYYYMMMMDDHHMMSS() -> String{
        let dateFormat = NSDateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMMddhhmmss")
        dateFormat.locale = NSLocale(localeIdentifier: "zh_CN")
        let strDate = dateFormat.stringFromDate(self)
        return strDate
    }
    
     ///格式化日期到字符串 YYYY年MM月
    func FormatToStringYYYYMM() -> String{
        let dateFormat = NSDateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("yyyyMMMM")
        dateFormat.locale = NSLocale(localeIdentifier: "zh_CN")
        let strDate = dateFormat.stringFromDate(self)
        return strDate
    }
    ///格式化日期到字符串 DD日HH小时MM分钟
    func FormatToStringDDHHMM() -> String{
        let dateFormat = NSDateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("ddhhmm")
        dateFormat.locale = NSLocale(localeIdentifier: "zh_CN")
        let strDate = dateFormat.stringFromDate(self)
        return strDate
    }
}
