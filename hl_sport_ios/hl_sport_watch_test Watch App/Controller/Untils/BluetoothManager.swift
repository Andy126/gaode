//
//  Bluetooth Manager.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/1.
//

import UIKit
import CoreBluetooth
import SwiftUI
import HomeKit
import WatchConnectivity

class BluetoothManager: NSObject, ObservableObject {

    //正常GL广播
    private let ScannerGLUUID = CBUUID(string: "FEFF")
    /// Scanner Device Service UUID 公开水域
    private let ScannerServiceUUID = CBUUID(string: "FDFF")
    //绑定广播
    private let ScannerBindUUID = CBUUID(string: "FCFF")

    private let Service_UUID = "1910"
    // CMD
    private let CMDNotifyCharacteristicUUID = CBUUID(string: "00010203-0405-0607-0809-0A0B0C0D2B10")
    private let CMDWriteCharacteristicUUID = CBUUID(string: "00010203-0405-0607-0809-0A0B0C0D2B11")
    private let CMDServiceUUID = CBUUID(string: "00010203-0405-0607-0809-0A0B0C0D1910")

    //中心设备管理器
    private var centralManager: CBCentralManager?
    //外设
    private var peripheral: CBPeripheral?
    private var devices = [LPDeviceInfo]()
    //保存记录的Mac "C4:19:D1:40:AF:10"
//    private var recordedMac = "C4:19:D1:97:91:BD"
    private var recordedMac = [String]()
    //连接的mac
    private var connectedMac = ""
    //绑定数据
    private var bindData = [[String: Any]]()
    
    //外设特征-写入
    private var writeCharacter: CBCharacteristic?
    
    //外设管理器
    private var perManager: CBPeripheralManager?
    //服务特征
    private var serviceCharacterist: CBMutableCharacteristic?
    //是否连接
    @Published var isConnect = false
    //运动中蓝牙状态
    @Published var showConnect = false
//    @Published var statestr = ""
//    var scanType = 1
    private var otaOffset: Int = 0
//    var countindex = 0
    //发指令
    var commTimer: Timer?
    //扫描中
    var scanning = false
   
    //单例实例
    private static let instance = BluetoothManager()
    //共有静态属性
    static let shared = instance
    
    //蓝牙logsting
     var logStr  = ""


    private override init() {
        super.init()
    }
    
    //蓝牙作为中心
    func initCenterManager() {
        recordedMac = [String]()
        //获取缓存mac地址
//        UserDefaults.standard.removeObject(forKey: "Holoswim_mac")
        if let data = UserDefaults.standard.array(forKey: "Holoswim_Bind_data") as? [[String: Any]] {
            bindData = data
//            recordedMac.removeAll()
            bindData.forEach { item in
                if let mac = item["deviceMac"] as? String {
                    recordedMac.append(mac)
                }
            }
        }
        
        if let mac = UserDefaults.standard.string(forKey: "Holoswim_mac"), !mac.isEmpty {
            if !recordedMac.contains(mac) {
                recordedMac.append(mac)
            }
        } else {
            //根据uuid查看绑定的泳镜mac地址和userid
            NetworkManager.shared.getDeviceInfo { [self] Mac, uId, List in
                if let mac = Mac, let uid = uId, let list = List {
//                    self.receiveData = ["mac": mac, "userId": uid]
//                    self.isReceive = true
                    self.recordedMac.append(mac)
                    self.bindData = list
                    list.forEach { item in
                        if let mac = item["deviceMac"] as? String {
                            recordedMac.append(mac)
                        }
                    }
                } else {
//                    self.isReceive = false
                    UserDefaults.standard.removeObject(forKey: "HSPrompted")
                }
            }
        }
        //初始化中心设备管理器
        centralManager = CBCentralManager(delegate: self, queue: nil)
        //扫描
//        scanForPeripheral()
    }
    
    //扫描外设广播 1.GL 2.开放水域 3.绑定
    func scanForPeripheral() {
        scanning = true
//        scanType = type
//        let uuid = type==1 ? ScannerGLUUID : type==2 ? ScannerServiceUUID : ScannerBindUUID
        centralManager?.scanForPeripherals(withServices: [ScannerServiceUUID], options: nil)
    }
    
    //写入数据
    func writeData(json: String) {
        if let data = json.data(using: .utf8), let character = writeCharacter {
            
            let time = Date().timeIntervalSince1970
            print("写入特征数据===\(time)")
            
            //外设写入特征数据
            self.peripheral?.writeValue(data, for: character, type: CBCharacteristicWriteType.withResponse)
        }
    }
}

extension BluetoothManager: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //判断蓝牙状态
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .unknown:
            print("未知")
        case .resetting:
            print("重置中")
        case .unauthorized:
            print("未验证")
        case .poweredOff:
            print("未启动")
        case .poweredOn:
            print("可用")
            if !recordedMac.isEmpty {
                //公开水域模式扫描
                scanForPeripheral()
            }
        case .unsupported:
            print("不支持")
        @unknown default:
            break
        }
    }
    
    //发现外设
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        printLog("发现外设")
//        self.peripheral = peripheral
//        statestr = "didDiscover"
//        print("设备名: \(peripheral.name)")
        print(advertisementData)
//        //根据外设名称过滤
//        if let isperi = peripheral.name?.hasPrefix("Holoswim"), isperi && peripheral.state == .disconnected {
//            //连接外设
//            central.connect(peripheral, options: nil)
//        }
        //解析特征包数据
        lp_AdvertisementDataToInfo(advertisementData: advertisementData, peripheral: peripheral, rssi: RSSI)
    }
    
    //连接成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        printLog("连接成功")
//        isConnect = true
//        statestr = peripheral.name ?? "-"
//        stopScan() //停止扫描
        //设置外设代理
        self.peripheral = peripheral
        peripheral.delegate = self
        peripheral.discoverServices([CMDServiceUUID])
        
        //缓存设备mac
        if !connectedMac.isEmpty {
            UserDefaults.setInfo(connectedMac, forKey: "Holoswim_mac")
        }
        //获取用户id
        if let data = bindData.filter({ item in
            item["deviceMac"] as? String == connectedMac
        }).first {
            if let uid = data["userId"] as? Int {
                NetworkManager.shared.userID = "\(uid)"
                UserDefaults.setInfo(uid, forKey: "HL_UserID")
            }
        }
    }
    
    //停止扫描
    func stopScan() {
        scanning = false
        self.centralManager?.stopScan()
    }
    
    //连接失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        printLog("连接失败")
        //        statestr = "didFailToConnect"
        //重连
        central.connect(peripheral)
    }
    
    //断开重连
    func reconnperipheral() {
        if let peri = self.peripheral {
            centralManager?.connect(peri)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        if let restoreIdentifiers = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [String] {
            for identifier in restoreIdentifiers {
//                central.connect(peripheralWithIdentifier: identifier, options: nil)
            }
        }
    }
    
    //断开连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        printLog("断开连接")
        isConnect = false
        showConnect = false
//        statestr = "didDisconnect"
        // 尝试重新连接
//        if !scanning {
//            central.connect(peripheral, options: nil)
//        }
        //蓝牙扫描
//        self.scanForPeripheral()
//        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
//            self.stopScan()
//        }
        // 外设断开连接后，保存 restoreIdentifier 以便自动重连
//        let restoreIdentifier = peripheral.restoreIdentifier
    }
    
    //发现服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        //根据UUID寻找服务中的特征
        //显示内容指令 "00010203-0405-0607-0809-0A0B0C0D2B11"
        if let service = peripheral.services?.last {
            //发现订阅和写入特征
            peripheral.discoverCharacteristics([CMDNotifyCharacteristicUUID, CMDWriteCharacteristicUUID], for: service)
        }
    }
    
    //发现特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        if let characteristics = service.characteristics, characteristics.count > 0 {
            
            for characteristic in characteristics {
                print("外设的特征：\(characteristic)")
                if characteristic.properties.contains(.notify) {
                    //订阅特征
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                    self.writeCharacter = characteristic
                    //连接成功后发送暂停指令3
                    sendDeviceInstruct()
                    var times = 0
                    commTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                        self.sendDataInstruct(ctrl: 3, hr: 0, time: 0, distance: 0, kcal: 0, pace: 0)
                        times += 1
                        if times > 3 {
                            timer.invalidate()
                            self.commTimer = nil
                        }
                    }
                }
            }
        }
    }
    
    //查询设备信息指令
    func sendDeviceInstruct() {
        print("查询设备信息指令")
        guard let peripheral = peripheral else { return }
        guard let characteristic = writeCharacter else { return }
        let data = LPBusinessInstruct.device.businessType.instruction.toData()
        writeValueForCharacteristic(peripheral: peripheral, characteristic: characteristic, value: data)
        let time = Date().timeIntervalSince1970
        printLog("查询设备信息指令===\(time)")
    }
    
    //下发数据指令
    func sendDataInstruct(ctrl: Int, hr: Int, time: Int, distance: Int, kcal: Int, pace: Int) {
//        print("数据指令")
        guard let peripheral = peripheral else { return }
        guard let characteristic = writeCharacter else { return }
        let time2 = Date().timeIntervalSince1970
        printLog("发送数据===\(time2)====ctrl===\(ctrl)===peripheral\(peripheral)===\(characteristic)")

        //数据下发指令
//        if ctrl != 3 {
//            self.countindex += 1
//        }
        let data = LPBusinessInstruct.swimInfo(ctrl: UInt8(ctrl), hr: hr, time: time, distance: distance, kcal: kcal, pace: pace, gps: true).businessType.instruction.toData()
        self.writeValueForCharacteristic(peripheral: peripheral, characteristic: characteristic, value: data)
    }
    
    //时间和坐标指令
    func sendTimeInstruct(distance: Int, signal: Bool, lon: Double, lat: Double, hr: Int) {
        guard let peripheral = peripheral else { return }
        guard let characteristic = writeCharacter else { return }
        let time = Date().timeIntervalSince1970
        printLog("时间和坐标指令===\(time)")
        
        //距离和坐标
        let coordData = LPBusinessInstruct.coord(distance: distance, signal: (signal ? 3 : 0), lon: (lon+180)*pow(10, 6), lat: (lat+90)*pow(10, 6)).businessType.instruction.toData()
        self.writeValueForCharacteristic(peripheral: peripheral, characteristic: characteristic, value: coordData)

        //心率、信号、时间
        let timeData = LPBusinessInstruct.time(hr: hr, signal: (signal ? 3 : 0)).businessType.instruction.toData()
        self.writeValueForCharacteristic(peripheral: peripheral, characteristic: characteristic, value: timeData)
    }
    
    /// 向设备特征写数据
    ///
    /// - Parameters:
    ///   - peripheral: 设备
    ///   - characteristic: 特征
    ///   - value: 数据
    func writeValueForCharacteristic(peripheral: CBPeripheral, characteristic: CBCharacteristic, value: Data) {
        if characteristic.properties.contains(.writeWithoutResponse) {
            /// 无响应
            peripheral.writeValue(value, for: characteristic, type: .withoutResponse)
//            print("\(characteristic.uuid.uuidString) did write characteristic value: \(Array(value)) without response")
        } else if characteristic.properties.contains(.write) {
            /// 有回复
            peripheral.writeValue(value, for: characteristic, type: .withResponse)
//            print("\(characteristic.uuid.uuidString) did write characteristic value: \(Array(value)) withResponse")
        } else {
            /// 不能写
            print("\(characteristic.uuid.uuidString) can not write value")
        }
    }
    
    /// 已经准备发送数据
    func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {

    }
    
    //订阅状态
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: (any Error)?) {
        if let error = error {
            printLog("订阅失败：\(error)")
            return
        }
        if characteristic.isNotifying {
            printLog("订阅成功")
        } else {
            printLog("取消订阅")
        }
    }
   
    /// 蓝牙向设备特征发数据之后回调此方法
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        print("---写入数据")
//        characteristic.properties
//        handleCharacteristicData(peripheral: peripheral, data: characteristic.value)
    }
    
    /// 读取到特征的值后回调此方法
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
//        statestr = "特征数据"
        if let val = characteristic.value {
            let data = [UInt8](val)
            guard data.count>3 else { return }
            printLog("收到数据：\(data)")
            
//            statestr = "\(data)"
//            statestr = "特征数据：\(str)"
            //处理外设特征数据
//            handleCharacteristicData(peripheral: peripheral, data: characteristic.value)
            //应答包
            if data[1] == 9 {
                //功能码为2 -数据下发 指令:254, 1, 2, 0, 12, 2:删除 1:保存
                if data[2] == 2 {
                    if data[5] == 0 {
                        //停止发暂停指令
                        isConnect = true
                        showConnect = true
                        commTimer?.invalidate()
                        commTimer = nil
                        
//                        //如果是保存或者删除停止WorkOut
//                        if WorkoutManager.shared.cTrol == 1 || WorkoutManager.shared.cTrol == 2{
//                            WorkoutManager.shared.stopWorkOut()
//                        }
                    }
                }
            }
            //
        }
    }
    
    //解析特征包
    func lp_AdvertisementDataToInfo(advertisementData: [String: Any], peripheral: CBPeripheral, rssi: NSNumber) {
        //广播包数据：MAC(6位)+Userid(4位)+GL
        guard let ManufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data else {
            return
        }

        let bytes: [UInt8] = Array(ManufacturerData)
        var mac = ""
        var userId = 0
        
        //mac获取
        if bytes.count > 6 {
            let end =  6
            let mac_strs: [String] = bytes[0..<end].compactMap{ String(format: "%02x", $0) }
            mac = mac_strs.joined(separator: ":").uppercased()
        }
//        self.devices.append(LPDeviceInfo(name: peripheral.name, udid: peripheral.identifier.uuidString, mac: mac, advertisementData: advertisementData, peripheral: peripheral, rssi: rssi))

        //连接记录的mac外设
        if recordedMac.contains(mac)  {
            centralManager?.connect(peripheral)
            self.peripheral = peripheral
            connectedMac = mac
        } else {
            //判断RSSI信号最强，记录Mac，连接设备
//            if let item = devices.max(by: { item1, item2 in
//                let val1 = item1.rssi?.intValue ?? -999
//                let val2 = item2.rssi?.intValue ?? -999
//                return val1 > val2
//            }) {
//                recordedMac = item.mac
//            }
        }
        
    //    let helderStrStart = bytes.count - 2
    //    let helderStr: [String] = bytes[helderStrStart..<bytes.count ].compactMap{ $0.toString }

        //userid获取
        if bytes.count >= 10 {
            let start = 6
            let uidBytes = Array(bytes[start..<(start+4)])
            if uidBytes.filter({ $0 == 0xff }).count == 4 {
//                bleBean.userId = nil
            } else {

                userId = uidBytes.toInt
            }
        }
        
        //广播头获取
        if bytes.count >= 12 {
            let helderStrStart = 10
            let helderStr: [String] = bytes[helderStrStart..<12].compactMap{ $0.toString }
            let headerBle = helderStr.joined()
            print("广播头：\(headerBle)")
        }

        //配对标志位获取
        if bytes.count >= 13 {
            let helderStrStart = 12
//            bleBean.garMinPair = LPCMDSwitchState.toBool(cmd: bytes[12])
    //        bleBean.headerBle = helderStr.joined()
        }
        
        #if DEBUG
        print(">>设备Mac:\(mac) | 设备UID:\(userId)")
        #endif
    }
}


extension [UInt8] {
    /// Convert Array UInt8 to Int
    public var toInt: Int {
        var value = 0
        for i in 0..<self.count {
            let shift = (self.count - 1 - i) * 8
            value += (Int(self[i]) & 0x000000FF) << shift
        }
        return value
    }
}

extension UInt8 {
    /// 转string
    var toString: String {
        String(bytes: [self], encoding: .utf8) ?? ""
    }
}

extension CBCharacteristic {
    
    public enum LPBleCharactersitcType: String {
        case read = "Read"
        case notify = "Notify"
        case write = "WriteAndRead"
        case writeWithoutResponse = "WriteWithoutResponse"
        case other = "Other"
    }
    
    /// 属性
    public var propertieTypes: [LPBleCharactersitcType] {
        var types: [LPBleCharactersitcType] = []
        
        if (properties.rawValue & CBCharacteristicProperties.read.rawValue) != 0 {
            types.append(.read)
        }
        
        if (properties.rawValue & CBCharacteristicProperties.write.rawValue) != 0 {
            types.append(.write)
        }
        
        if (properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0 {
            types.append(.writeWithoutResponse)
        }
        
        if (properties.rawValue & CBCharacteristicProperties.notify.rawValue) != 0 {
            types.append(.notify)
        }
        
        return types
    }
    
    /// 是否可以订阅
    public var isNotify: Bool {
        return (properties.rawValue & CBCharacteristicProperties.notify.rawValue) != 0
    }
    
    /// 是否可写
    public var isWrite: Bool {
        return ((properties.rawValue & CBCharacteristicProperties.write.rawValue) != 0) ||
        ((properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0)
    }
    
    /// 是否可读
    public var isRead: Bool {
        return (properties.rawValue & CBCharacteristicProperties.read.rawValue) != 0
    }
    
    public var writeType: CBCharacteristicWriteType {
        let types = propertieTypes
        if types.contains(.write) {
            return .withResponse
        } else {
            return .withoutResponse
        }
    }
    
    /// 属性字符串
    public var propertiesString: String {
        let types = propertieTypes
        var str:String = types.map{ $0.rawValue }.joined(separator: ",")
        return str
    }
    
    /// 转为指令
    public func transformer() -> [UInt8]? {
        
        return nil
    }
}

extension UInt16 {
    //转UInt8s字符串
    public var UInt8s: [UInt8] {
        return [UInt8(0xff),
                UInt8((0xff00) >> 8)]
    }
}

extension Data {
    ///CRC协议校验内容
    public var crc16: UInt16? {
        
        guard self.isEmpty else {
            return nil
        }
        let bytes: [UInt8] = Array(self)
        
        var crc: UInt16 = 0xffff
        let polynominal: UInt16 = 0xa001
        for i in 0..<bytes.count {
            crc ^= UInt16(bytes[i])
            for _ in 0..<8 {
                if (crc & 0x0001) != 0 {
                    crc >>= 1
                    crc ^= polynominal
                } else {
                    crc >>= 1
                }
            }
        }
        return crc
    }
    
    ///转整形
    public var toInt: Int {
        return withUnsafeBytes { $0.load(as: Int.self) }
    }
}
//打印log
func printLog(_ str: String = " ", separator: String = " ", terminator: String = "\n") {
    BluetoothManager.shared.logStr =  BluetoothManager.shared.logStr + "\n" + str
    
}
