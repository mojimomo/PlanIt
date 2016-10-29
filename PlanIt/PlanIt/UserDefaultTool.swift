//
//  UserDefaultTool.swift
//  Markplan
//
//  Created by Ken on 16/10/6.
//  Copyright © 2016年 Ken. All rights reserved.
//

import Foundation
class UserDefaultTool: NSObject {
    /// let修饰常量是线程安全
    static let shareIntance : UserDefaultTool = UserDefaultTool()

    override init() {
        super.init()
    }
    
    //几天后推送
    var daysLocalNotifiication : Int{
        get{
//            if UserDefaults.standard.integer(forKey: "daysLocalNotifiication") as Int! == 0{
//                UserDefaults.standard.set( 3 , forKey: "daysLocalNotifiication")
//            }
//            return UserDefaults.standard.integer(forKey: "daysLocalNotifiication") as Int
            return 1;
        }
        set{
            //UserDefaults.standard.set( newValue , forKey: "daysLocalNotifiication")
        }
    }
    //几条推送
    var numsLocalNotifiication : Int{
        get{
            if UserDefaults.standard.value(forKey: "numsLocalNotifiication") == nil{
                UserDefaults.standard.set( 0 , forKey: "numsLocalNotifiication")
            }
            return UserDefaults.standard.integer(forKey: "numsLocalNotifiication") as Int
        }
        set{
            UserDefaults.standard.set( newValue , forKey: "numsLocalNotifiication")
        }
    }
    
    //是否每天推送
    var isEveryDayLocalNotifiication : Bool{
        get{
            if UserDefaults.standard.value(forKey: "isEveryDayLocalNotifiication") == nil{
                UserDefaults.standard.set( false , forKey: "isEveryDayLocalNotifiication")
            }
            return UserDefaults.standard.bool(forKey: "isEveryDayLocalNotifiication") as Bool
        }
        set{
            UserDefaults.standard.set( newValue , forKey: "isEveryDayLocalNotifiication")
        }
    }
    
    //是否开启结束推送
    var isBeforeDueNotifiication : Bool{
        get{
            if UserDefaults.standard.value(forKey: "isBeforeDueNotifiication") == nil{
                UserDefaults.standard.set( false , forKey: "isBeforeDueNotifiication")
            }
            return UserDefaults.standard.bool(forKey: "isBeforeDueNotifiication") as Bool
        }
        set{
            UserDefaults.standard.set( newValue , forKey: "isBeforeDueNotifiication")
        }
    }
    
    //打开次数
    var numsOfOpenTimes : Int{
        get{
            if UserDefaults.standard.value(forKey: "numsOfOpenTimes") == nil{
                UserDefaults.standard.set( 0 , forKey: "numsOfOpenTimes")
            }
            return UserDefaults.standard.integer(forKey: "numsOfOpenTimes") as Int
        }
        set{
            UserDefaults.standard.set( newValue , forKey: "numsOfOpenTimes")
        }
    }
    
    //每日推送的时间
    var timeOfEveryday : Date{
        get{
            if UserDefaults.standard.value(forKey: "timeOfEveryday") == nil{
                let date = "21:00".FormatToNSDateHHMM()
                UserDefaults.standard.set( date , forKey: "timeOfEveryday")
            }
            return UserDefaults.standard.object(forKey: "timeOfEveryday") as! Date
        }
        set{
            UserDefaults.standard.set( newValue , forKey: "timeOfEveryday")
        }
    }
}
