//
//  LiveData.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/15.
//

import Foundation

@objcMembers
class LiveData: NSObject, Codable {
    
    //距离（米）
    var distance: Double = 0
    //心率（次/分）
    var heartRate: Int = 0
    //消耗能量（千卡）
    var calorie: Double = 0
    //配速（秒/百米）
    var pace: Int = 0
    //划水次数
    var strokeTimes: Int = 0
    //数据来源
    var source = "Apple Watch"
    //日期
    var timestamp: Int = Int(round(Date().timeIntervalSince1970))
    
    override init() {
        super.init()
    }
    
    init(distance: Double, heartRate: Int, calorie: Double, pace: Int, strokeTimes: Int,source: String) {
        self.distance = distance
        self.heartRate = heartRate
        self.calorie = calorie
        self.pace = pace
        self.strokeTimes = strokeTimes
        self.source = source

    }
    
    //判断数据不为空
    func fullData() -> Bool {
        // speed>0 strokes>0 distance>0
        if heartRate>0 && calorie>0 {
            timestamp = Int(round(Date().timeIntervalSince1970))
            return true
        }
        return false
    }
    
    //数据归零
    func zero() {
        self.distance = 0
        self.heartRate = 0
        self.calorie = 0
        self.pace = 0
        self.source = "Apple Watch"
        self.strokeTimes = 0
        self.timestamp = Int(round(Date().timeIntervalSince1970))
    }
    
    //转json字符串
    func toJSON() -> String {
        if let data = try? JSONEncoder().encode(self) {
            if let str = String(data: data, encoding: .utf8) {
                
                return str
            }
        }
        return ""
    }
}
