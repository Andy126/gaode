//
//  MotionData.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/15.
//

import Foundation

@objcMembers
class MotionData: NSObject, Codable {
    
    //Identifiable
//    var id = UUID()
    //类型 OPEN_WATER - 公开水域游泳
    var type = "OPEN_WATER"
    //总时长（秒）
    var totalDurationTime: Int = 0
    //开始时间
    var startTime: String = ""
    //开始时间戳
    var startTimestamp: Int = 0
    //结束时间
    var endTime: String = ""
    //结束时间戳
    var endTimestamp: Int = 0
    //时区
    var timeZone: String = "Asia/Shanghai"
    //长度单位 1-米，2-码
    var lengthUnit: Int = 1
    //总距离（米）
    var totalDistance: Double = 0
    //平均心率（次/分）
    var averageHeartRate: Int = 0
    //总消耗能量（千卡）
    var totalCalorie: Double = 0
    //平均配速（秒/米）
//    var averageSpeed: Double = 0
    //总划水次数
    var totalStrokeTimes: Int = 0
    //平均划水频率（单位：次/分钟）
    var averageStrokeRate: Int = 0
    //最大划水频率（单位：次/分钟）
    var maxStrokeRate: Int = 0

    //泳姿：FR-自由泳，BK-仰泳，MX-混合泳，BR-蛙泳，BT-蝶泳，打腿-K，划手-P
    var strokeType = ""
    //运动详细数据
    var detailList: [LiveData]?

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
