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
    
    ///计算此时间与结束时间相差几周
    func weeksToEndDate(endDate: NSDate) -> Int{
        let timeEnd = endDate.timeIntervalSince1970
        let timeBegin = self.timeIntervalSince1970
        let days = (timeEnd - timeBegin)/( 60 * 60 * 24 * 7)
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
        
        //判断是否是负
        if timeInterval < 0{
            timeInterval = -timeInterval
        }
        
        //判断时间
        if timeInterval < 60{
            result += "1 分"
        }else if timeInterval / 60 < 60 {
            tmp = (timeInterval / 60 ).toIntCarry()
            result += "\(tmp) 分"
        }else if timeInterval / 60 / 60 < 24 {
            tmp = (timeInterval / 60 / 60).toIntCarry()
            result += "\(tmp) 小时"
        }else {
            tmp = (timeInterval / 60 / 60 / 24 ).toIntCarry()
            result += "\(tmp) 天"
//        }else if timeInterval / 60 / 60 / 24 / 30 < 12 {
//            tmp = (timeInterval / 60 / 60 / 24 / 30 ).toIntCarry()
//            result += "\(tmp) 月"
//        }else{
//            tmp = (timeInterval / 60 / 60 / 24 / 30 / 12).toIntCarry()
//            result += "\(tmp) 年"
        }
        return result
    }
    
    ///增加一天
    func increase1Day() -> NSDate? {
        let day = 1.0
        let nextDate = self.dateByAddingTimeInterval(day * 24 * 60 * 60)
        return nextDate
        
    }
    
    ///增加几天
    func increaseDays(day: Double) -> NSDate? {
        let nextDate = self.dateByAddingTimeInterval(day * 24 * 60 * 60)
        return nextDate
    }
    
    ///增加一月
    func increase1Month() -> NSDate? {
        let newDateComponents = NSDateComponents()
        newDateComponents.month = 1
        let calculatedDate = NSCalendar.currentCalendar().dateByAddingComponents(newDateComponents, toDate: self, options: NSCalendarOptions.init(rawValue: 0))
        return calculatedDate
    }    
    
    ///增加几月
    func increaseMonths(month: Int) -> NSDate? {
        let newDateComponents = NSDateComponents()
        newDateComponents.month = month
        let calculatedDate = NSCalendar.currentCalendar().dateByAddingComponents(newDateComponents, toDate: self, options: NSCalendarOptions.init(rawValue: 0))
        return calculatedDate
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
    
    ///格式化日期到字符串 MM月
    func FormatToStringMMMM() -> String{
        let dateFormat = NSDateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("MMMM")
        dateFormat.locale = NSLocale(localeIdentifier: "zh_CN")
        let strDate = dateFormat.stringFromDate(self)
        return strDate
    }
    
    ///格式化日期到字符串 YYYY年
    func FormatToStringYYYY() -> String{
        let dateFormat = NSDateFormatter()
        dateFormat.setLocalizedDateFormatFromTemplate("yyyy")
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
    
    ///获取这是这个月的第几周
    func getWeekOfMonth() -> Int{
        let calendar:NSCalendar = NSCalendar.currentCalendar()
        let dateComp:NSDateComponents = calendar.components( .WeekOfMonth, fromDate: self)
        return dateComp.weekOfMonth
    }
    
    ///获取这是这个年的第几月
    func getMonthkOfYear() -> Int{
        let calendar:NSCalendar = NSCalendar.currentCalendar()
        let dateComp:NSDateComponents = calendar.components( .Month, fromDate: self)
        return dateComp.month
    }
    
    ///获取这是这个年的第几月
    func getWeekOfYear() -> Int{
        let calendar:NSCalendar = NSCalendar.currentCalendar()
        let dateComp:NSDateComponents = calendar.components( .WeekOfYear, fromDate: self)
        return dateComp.weekOfYear
    }
    
    ///获取这个月的第一天和最后一天
    func getMonthBeginAndEnd() -> (firstDay: NSDate?, lastDay: NSDate?){        
        let calendar:NSCalendar = NSCalendar.currentCalendar()
        var intervalCount: NSTimeInterval = 0
        let newDateString = self.FormatToStringYYYYMM()
        let newDate = newDateString.FormatToNSDateYYYYMMMM()!
        var firstDay: NSDate?
        var lastDay: NSDate?
        if calendar.rangeOfUnit(.NSMonthCalendarUnit, startDate: &firstDay, interval: &intervalCount, forDate: newDate){
            firstDay = firstDay?.increase1Day()
            lastDay = firstDay?.dateByAddingTimeInterval(intervalCount - 1)
        }
        return (firstDay, lastDay)
    }
 }
