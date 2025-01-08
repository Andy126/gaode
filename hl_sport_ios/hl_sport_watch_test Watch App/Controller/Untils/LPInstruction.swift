//
//  LPInstruction.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/29.
//

import Foundation

public enum LPBusinessInstruct {
    //显示内容
    case display
    //获取传感器数据
    case fetchSensorData(page: Int)
    //配对模式-修改广播
//    case setPair
    //查询设备
    case device
    //控制命令
    case control
    //游泳数据下发
    case swimInfo(ctrl: UInt8, hr: Int, time: Int, distance: Int, kcal: Int, pace: Int, gps: Bool)
    //轨迹坐标
    case coord(distance: Int, signal: Int, lon: Double, lat: Double)
    //时间下发
    case time(hr: Int, signal: Int)
    //解绑
    case unBindUID
 }


// MARK: - 泳姿
public enum LPBusinessBleSwimStroke {

    /// 无限制
    case CH
    /// 自由泳
    case FR
    /// 仰泳
    case BR
    /// 混合泳
    case MX
    /// 训练
    case DR
    /// 休息
    case REST
    /// 蛙泳
    case Breaststroke
    /// 蝶泳
    case Butterfly
    /// 未知
    case unKnown
    
    static func toSwimStroke(code: UInt8) -> LPBusinessBleSwimStroke {
        
        if code == 0x00 {
            return .CH
        } else if code == 0x01 {
            return .FR
        } else if code == 0x02 {
            return .BR
        } else if code == 0x03 {
            return .MX
        } else if code == 0x04 {
            return .DR
        } else if code == 0x05 {
            return .REST
        } else if code == 0x06 {
            return .Breaststroke
        } else if code == 0x07 {
            return .Butterfly
        } else {
            return .unKnown
        }
    }
    
    public var code: UInt8 {
        switch self {
        case .CH:   return 0x00
        case .FR:   return 0x01
        case .BR:   return 0x02
        case .MX:   return 0x03
        case .DR:   return 0x04
        case .REST: return 0x05
        case .Breaststroke: return 0x06
        case .Butterfly:    return 0x07
        case .unKnown:      return 0x01
        }
    }
}

extension LPBusinessInstruct {
    
    var businessType: LPBleBusinessInstruction {
        //生成指令
        switch self {
        case .display:
            return .common(cmd: 0x23)
        case .fetchSensorData(page: let page):
            return .commonPayload(cmd: 0x40, payload: [0xFF,0xFF,0xFF,0xFF])
//        case .setPair:
//            return .common(cmd: 0x0D)
        case .device:
            return .commonPayload(cmd: 0x00, payload: [0x00])
        case .control:
            //0:开始/继续 1:保存 2:删除 3:暂停 其他:保留 ,0x01,0x02,0x03
            return .commonPayload(cmd: 0x01, payload: [0x00])
        case .swimInfo(let ctrl, let hr, let time, let distance, let kcal, let pace, let gps):
//            let stateRow = [UInt8(ctrl)]
            let stateRow = [ctrl]
            let hrRow = [hr.toUInt8()]
//            let strokeRow = [stroke.code]
            let timeRow = time.timeUnit8(time: time)
            let distanceRow = distance.toUInt8sZeroFirst(bytesCount: 2)
            let kcalRow = kcal.toUInt8sZeroFirst(bytesCount: 2)
            let paceRow = pace.msUnit8(time: pace)
            let gpsRow = [UInt8(gps ? 0x03 : 0x00)]

            var rowArr = [UInt8]()
            rowArr.append(contentsOf: stateRow)
            rowArr.append(contentsOf: hrRow)
            rowArr.append(contentsOf: timeRow)
//            rowArr.append(contentsOf: strokeRow)
            rowArr.append(contentsOf: distanceRow)
            rowArr.append(contentsOf: kcalRow)
            rowArr.append(contentsOf: paceRow)
            rowArr.append(contentsOf: gpsRow)
            return .commonPayload(cmd: 0x02, payload: rowArr)
        case .coord(let distance, let signal, let lon, let lat):
            //轨迹坐标
            let distanceRow = distance.toUInt8sZeroFirst(bytesCount: 2)
            let signalRow = [UInt8(signal == 3 ? 0x03 : signal == 0 ? 0x00 : 0x02)]
            let lonRow = (lon+180).bigEndianData
            let latRow = (lat+90).bigEndianData
            
            var rowArr = [UInt8]()
            rowArr.append(contentsOf: distanceRow)
            rowArr.append(contentsOf: signalRow)
            rowArr.append(contentsOf: lonRow)
            rowArr.append(contentsOf: latRow)
            return .commonPayload(cmd: 0x03, payload: rowArr)
        case .time(let hr, let signal):
            let hrRow = hr.toUInt8sZeroFirst(bytesCount: 2)
            let signalRow = [UInt8(signal == 3 ? 0x03 : signal == 0 ? 0x00 : 0x02)]
            let timeRow = dateTimeUnit8()

            var rowArr = [UInt8]()
            rowArr.append(contentsOf: hrRow)
            rowArr.append(contentsOf: signalRow)
            rowArr.append(contentsOf: timeRow)
            return .commonPayload(cmd: 0x04, payload: rowArr)
        case .unBindUID:
            return .commonPayload(cmd: 0x05, payload: [0x00])
        }
    }
    
    //获取当前时间(年月日时分秒星期时区)的UInt8
    public func dateTimeUnit8() -> [UInt8] {
    
        let comp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: Date())
        
        // 获取当前时区
        let timeZone = TimeZone.current
        // 获取时区相对于UTC的偏移量（以秒为单位）
        let secondsFromGMT = timeZone.secondsFromGMT()
        // 将秒转换为小时和分钟
        let offsetHours = secondsFromGMT / 3600
        let offsetMinutes = (secondsFromGMT % 3600) / 60
        // 计算时区偏移量（加12后再扩大10倍）
        let adjustedOffset = ((offsetHours + offsetMinutes / 60) + 12) * 10

        return [comp.year!.toUInt8(),
                comp.month!.toUInt8(),
                comp.day!.toUInt8(),
                comp.hour!.toUInt8(),
                comp.minute!.toUInt8(),
                comp.second!.toUInt8(),
                comp.weekday!.toUInt8(),
                adjustedOffset.toUInt8()]
    }
}


extension Double {
    public var bigEndianData: Data {
        var double = self
        return Data(bytes: &double, count: MemoryLayout<Double>.size)
    }
    
    /// 生成指定长度UInt8集合0高位补齐
    public func toUInt8sZeroFirst(bytesCount: Int) -> [UInt8] {
        let data = Array(self.bigEndianData.reversed())
        let count = (data.count > bytesCount) ? bytesCount : data.count
        let result = [UInt8](data[(data.count-count)..<data.count])
        return result
    }
}

extension Int {
    
    public var bigEndianData: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<Int>.size)
    }
    
    /// 生成指定长度UInt8集合0高位补齐
    public func toUInt8sZeroFirst(bytesCount: Int) -> [UInt8] {
        let data = Array(self.bigEndianData.reversed())
        let count = (data.count > bytesCount) ? bytesCount : data.count
        let result = [UInt8](data[(data.count-count)..<data.count])
        return result
    }
    
    /// 生成单长度UInt8
    public func toUInt8() -> UInt8 {
        let data = self.bigEndianData
        let result = [UInt8](data[0..<1])
        return result[0]
    }
    
    ///时长转unint8
    ///时长:01:15:85 代表 0x01(1小时)0x0F(15分钟)0x15(21秒); -6进制
    ///
    public func timeUnit8(time: Int) -> [UInt8] {
        let h = time/60/60
        let m = time/60%60
        let s = time%60

        return [h.toUInt8(),
                m.toUInt8(),
                s.toUInt8()]
    }
    
    public func msUnit8(time: Int) -> [UInt8] {
        let min = time/60
        let second = time%60

        return [min.toUInt8(), second.toUInt8()]
    }
}

public protocol LPInstruction {
    /// 包头（1字节）
    var header: UInt8 { get set }
    /// 包属性（1字节）
    var type: UInt8 { get set }
    /// 指令（1字节）
    var cmd: UInt8 { get set }
    /// 长度（2字节）
    var length: UInt16 { get set }
    /// 数据包，大小不定
    var payload: [UInt8] { get set }
    
    //应答ack
    var ack: [UInt8] { get set }
    //指令集合，除去checksum，校验自动计算
    func instructionBytes() -> [UInt8]
}

// MARK: 指令结构体
public struct LPBleInstruction: LPInstruction {
    
    public var header: UInt8
    public var type: UInt8
    public var cmd: UInt8
    public var length: UInt16
    public var payload: [UInt8]
    public var ack: [UInt8]
    
    init(header: UInt8, type: UInt8, cmd: UInt8, payload: [UInt8], ack: [UInt8]) {
        self.header = header
        self.type   = type
        self.cmd    = cmd
        self.length = UInt16(payload.count + ack.count)
        self.payload = payload
        self.ack = ack
    }
}

// MARK: 指令业务枚举
public enum LPBleInstructionBusinessType {
    case common(cmd: UInt8, payload: [UInt8])
    case commonEmptyPayload(cmd: UInt8)
    case commonACK(cmd: UInt8)
}

extension LPBleInstructionBusinessType {
    
    var instruction: LPBleInstruction {
        var payloads: [UInt8] = []
        var ack: [UInt8] = []
        var CMD: UInt8!

        switch self {
        case .common(let cmd, let payload):
            CMD = cmd
            payloads = payload
            ack = []
        case .commonACK(let cmd):
            CMD = cmd
            payloads = [0x00]
            ack = [0x09]
        case .commonEmptyPayload(let cmd):
            CMD = cmd
            payloads = [0x00]
            ack = []
        }
        
        return LPBleInstruction(header: 0xFE,
                                 type: 0x01,
                                 cmd: CMD,
                                 payload: payloads,
                                 ack: ack)
    }
    
}

// MARK: Business Instruction
public struct LPBleBusinessInstruction {
    
    var instruction: LPBleInstruction
    
    var characteristicUUID: String
        
    init(instruction: LPBleInstruction, characteristicUUID: String) {
        self.instruction = instruction
        self.characteristicUUID = characteristicUUID
    }
}

extension LPBleBusinessInstruction {
    /// 通用指令
    /// - Parameters:
    ///   - cmd: 指令
    ///   - uuid: 指令发送地址
    /// - Returns: 指令对象
    public static func common(cmd: UInt8, uuid: String = "00010203-0405-0607-0809-0A0B0C0D2B11") -> LPBleBusinessInstruction {
        return LPBleBusinessInstruction(instruction: LPBleInstruction.businss(.commonEmptyPayload(cmd: cmd)), characteristicUUID: uuid)
    }
    
    /// 通用带数据包指令
    public static func commonPayload(cmd: UInt8,
                                     payload:[UInt8],
                                     uuid: String = "00010203-0405-0607-0809-0A0B0C0D2B11") -> LPBleBusinessInstruction {
        return LPBleBusinessInstruction(instruction: LPBleInstruction.businss(.common(cmd: cmd, payload: payload)), characteristicUUID: uuid)
    }
    
    
    public static func ack(cmd: UInt8, uuid: String = "00010203-0405-0607-0809-0A0B0C0D2B11") -> LPBleBusinessInstruction{
        return LPBleBusinessInstruction(instruction: LPBleInstruction.businss(.commonACK(cmd: cmd)), characteristicUUID: uuid)
    }
    
    /// 添加包装器，便于结果解析
//    internal mutating func addWrapper(wrapper: LPBusinessBleInstructWrapper) -> LPBleBusinessInstruction {
//        self.wrapper = wrapper
//        return self
//    }
}

extension LPInstruction {
    
    static func businss(_ type: LPBleInstructionBusinessType) -> LPBleInstruction {
        return type.instruction
    }
    
    public func instructionBytes() -> [UInt8] {
        var bytes = [UInt8]()
        bytes.append(header)
        bytes.append(type)
        bytes.append(cmd)
        bytes += length.magnitude.toBytes
        bytes += payload
        //ack长度为1生效
        if ack.count == 1 {
            bytes += ack
        }
        
        return bytes
    }
    
    public func toData() -> Data {
        var bytes = instructionBytes()
        
        let crc = bytes.reduce(0x10000) { $0 - Int($1) }
        bytes += UInt16(crc).toBytes
        let sendData = Data(bytes)

        #if DEBUG
        var bytesStr = bytes.compactMap { String($0, radix: 16, uppercase: true) }.joined(separator: " ")
        if bytesStr.count < 2 {
            bytesStr = "0"+bytesStr
        }
        let comStr = "生成指令"+bytesStr
//        NSLog("INFO: BLE \(comStr)")
        
        #endif
        return sendData
    }
}


extension UInt16 {
    var toBytes: [UInt8] {
        return toByteArr(endian: self.bigEndian, count: MemoryLayout<UInt16>.size)
    }
    
    public func toByteArr<T: BinaryInteger>(endian: T, count: Int) -> [UInt8] {
        var _endian = endian
        let bytePtr = withUnsafePointer(to: &_endian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        return [UInt8](bytePtr)
    }
    
}

extension Date {
    
    public var l_syncTime: [UInt8] {
        let calendar = Calendar.current
        let y = calendar.component(.year, from: self)
        let M = calendar.component(.month, from: self)
        let d = calendar.component(.day, from: self)
        let wd = calendar.component(.weekday, from: self)
        let h = calendar.component(.hour, from: self)
        let m = calendar.component(.minute, from: self)
        let s = calendar.component(.second, from: self)
        let weekday = wd == 1 ? 7 : wd - 1
        
        return [toInt(y - 2000), toInt(M), toInt(d), toInt(weekday), toInt(h), toInt(m), toInt(s)]
    }
    
    func toInt(_ hex: Int) -> UInt8{
        return UInt8(String(hex), radix: 16) ?? 0
    }
}
