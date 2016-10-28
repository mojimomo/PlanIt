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
            if UserDefaults.standard.integer(forKey: "numsLocalNotifiication") as Int! == 0{
                UserDefaults.standard.set( 0 , forKey: "numsLocalNotifiication")
            }
            return UserDefaults.standard.integer(forKey: "daysLocalNotifiication") as Int
        }
        set{
            UserDefaults.standard.set( newValue , forKey: "numsLocalNotifiication")
        }
    }
    
    //是否每天推送
    var isEveryDayLocalNotifiication : Bool{
        get{
            if UserDefaults.standard.bool(forKey: "isEveryDayLocalNotifiication") as Bool! != true{
                UserDefaults.standard.set( false , forKey: "isEveryDayLocalNotifiication")
            }
            return UserDefaults.standard.bool(forKey: "isEveryDayLocalNotifiication") as Bool
        }
        set{
            UserDefaults.standard.set( newValue , forKey: "isEveryDayLocalNotifiication")
        }
    }
    
    //是否开启结束推送
    var isEOverLocalNotifiication : Bool{
        get{
            if UserDefaults.standard.bool(forKey: "isOverLocalNotifiication") as Bool! != true{
                UserDefaults.standard.set( false , forKey: "isOverLocalNotifiication")
            }
            return UserDefaults.standard.bool(forKey: "isOverLocalNotifiication") as Bool
        }
        set{
            UserDefaults.standard.set( newValue , forKey: "isOverLocalNotifiication")
        }
    }
    
    //打开次数
    var numsOfOpenTimes : Int{
        get{
            if UserDefaults.standard.integer(forKey: "numsOfOpenTimes") as Int! == 0{
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
            if UserDefaults.standard.object(forKey: "timeOfEveryday") as! Date? == nil{
                let date = "21:00".FormatToNSDateHHMM()
                UserDefaults.standard.set( Date() , forKey: "timeOfEveryday")
            }
            return UserDefaults.standard.object(forKey: "timeOfEveryday") as! Date
        }
        set{
            UserDefaults.standard.set( newValue , forKey: "timeOfEveryday")
        }
    }
}
