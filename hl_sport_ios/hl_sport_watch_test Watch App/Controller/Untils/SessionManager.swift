//
//  SessionManager.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/1.
//

import UIKit
import WatchConnectivity
import WatchKit

class SessionManager: NSObject, ObservableObject {
    
    //接收到的数据
    @Published var isReceive: Bool = false
    @Published var receiveData: [String: Any]?

    //单例实例
    private static let instance = SessionManager()
    //共有静态属性
    static let shared = instance

    open class var `default`: SessionManager {
        return instance
    }

    private override init() {
        super.init()
        
//        do {
//            try WCSession.default.updateApplicationContext(["a":"b"])
//        } catch {
//        }
        //初始化Session
        configureWCSession()
        //查询绑定信息
        self.getDeviceInfo()
//        Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
//        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
//            if self.isReceive {
////                timer.invalidate()
//            } else {
//                self.getDeviceInfo()
//            }
//        }
    }
    
    //查询绑定信息
    func getDeviceInfo() {
        //根据uuid查看绑定的泳镜mac地址
        NetworkManager.shared.getDeviceInfo { Mac, uId, List  in
            DispatchQueue.main.async {
                if let mac = Mac, let uid = uId {
                    self.receiveData = ["mac": mac, "userId": uid]
                    self.isReceive = true
                } else {
                    self.isReceive = false
                    UserDefaults.standard.removeObject(forKey: "HSPrompted")
                }
                UserDefaults.standard.synchronize()
//                self.objectWillChange.send()
            }
        }
    }
    
    func configureWCSession() {
        // Don't need to check isSupport state, because session is always available on WatchOS
        // if WCSession.isSupported() {}
        let session = WCSession.default
        session.delegate = self
        session.activate()
        if session.isCompanionAppInstalled {
            //后台传输数据
//            let wkuuid = UUID().uuidString
//            let devModel = WKInterfaceDevice.current().model
//            session.transferUserInfo(["getUUid":wkuuid,"thirdName":devModel])
            //发送应用程序退出，后台继续传输
//            session.updateApplicationContext(["uuid": UUID().uuidString])
        } else {
            print("未连接手机")
            //共享读写基本数据
//            UserDefaults(suiteName: "Groups1")
            //在共享文件目录中读写文件数据
//            FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "Groups1")
        }
    }
    
    //给手机发送消息
    func sendMsgToiPhone(msg: [String: Any], success: @escaping(([String: Any])->Void)) {
        
        if !WCSession.default.isReachable {
//            let action = WKAlertAction(title: "OK", style: .default) {
//                print("OK")
//            }
//            presentAlert(withTitle: "Failed", message: "Apple Watch is not reachable.", preferredStyle: .alert, actions: [action])
            return
        } else {
            // The counterpart is not available for living messageing
        }
        
//        let wkuuid = UUID().uuidString
//        let devModel = WKInterfaceDevice.current().model
//        sessionMg.sendMsgToiPhone(msg: ["getUUid":wkuuid,"thirdName":devModel]) { replyInfo in
//            print(replyInfo)
//        }

//        let date = Date(timeIntervalSinceNow: 0.0)
//        let message = ["title": "Apple Watch send a messge to iPhone", "watchMessage": "The Date is \(date.description)"]
        WCSession.default.sendMessage(["getUUid":"wkuuid","thirdName":"devModel"], replyHandler: { (replyMessage) in
            print(replyMessage)
            success(replyMessage)
//            DispatchQueue.main.sync {
//                self.contentLabel.setText(replyMessage["replyContent"] as? String)
//            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

extension SessionManager: WCSessionDelegate {
    
    //后台收到全局数据
//    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) { 
//        handleReceiveData(userInfo: applicationContext)
//    }
    
    //激活完成
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if error == nil {
            print(activationState.rawValue)
//            session.sendMessage(["test":"123"]) { info in }
        } else {
            print(error!.localizedDescription)
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        print(session)
    }
    
    //处理收到的数据
    func handleReceiveData(userInfo: [String: Any]) {
        receiveData = userInfo
       
        //解析数据
        if let mac = userInfo["mac"] as? String {
            //获取mac地址并缓存
            UserDefaults.standard.setValue(mac, forKey: "Holoswim_mac")
            DispatchQueue.main.async {
                self.isReceive = true
//                self.objectWillChange.send()
            }

            UserDefaults.setInfo(true, forKey: "HL_PhoneConfigured")
        }
        if let uid = userInfo["userId"] as? Int {
            NetworkManager.shared.userID = "\(uid)"
            UserDefaults.standard.setValue(uid, forKey: "HL_UserID")
        }
        if let countryCode = userInfo["countryCode"] as? String {
            NetworkManager.shared.countryCode = countryCode
            UserDefaults.standard.setValue(countryCode, forKey: "HL_CountryCode")
        }
        UserDefaults.standard.synchronize()
        
        //后台传输数据
        let wkuuid = UUIDTool.getUUID()
        let devModel = WKInterfaceDevice.current().model
        
        DispatchQueue.main.async {
            let info = WCSession.default.transferUserInfo(["getUUid":wkuuid,"thirdName":devModel])
            if info.isTransferring {
                print("传输中")
            }
            self.receiveData = info.userInfo
        }
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//            if info.userInfo.isEmpty {
//                do {
//                    try WCSession.default.updateApplicationContext(["getUUid":wkuuid,"thirdName":devModel])
//                } catch {
//                    print(error.localizedDescription)
//                }
//            }
//            if userInfo["didReceiveUserInfo"] != nil {
//                timer.invalidate()
//            }
//        }
    }
    
    //后台收到info数据
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("session userInfo: \(userInfo)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.handleReceiveData(userInfo: userInfo)
        }

        
        
        
//        DispatchQueue.main.sync {
////            contentLabel.setText(message["iPhoneMessage"] as? String)
//            let wkuuid = UUIDTool.getUUID()
//            let devModel = WKInterfaceDevice.current().model
//            session.transferUserInfo(["getUUid":wkuuid,"thirdName":devModel])
//        }
    }
    
    //前台收到消息数据
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print(message)
        handleReceiveData(userInfo: message)
        
        

        
        
        //回复收到
//        replyHandler(["replyContent": "didReceiveMessage"])
//        replyHandler(["title": "received successfully", "replyContent": "This is a reply from watch"])
//        DispatchQueue.main.sync {
//            contentLabel.setText(message["iPhoneMessage"] as? String)
//        }
        
//        let wkuuid = UUID().uuidString
//        let devModel = WKInterfaceDevice.current().model
//        let msg = ["getUUid":"wkuuid","thirdName":"devModel"]
//        session.sendMessage(msg, replyHandler: { (replyMessage) in
//            print(replyMessage)
//        }) { (error) in
//            print(error.localizedDescription)
//            self.isReceive = true
//            self.receiveData = ["msg": error.localizedDescription]
//        }
    }
}
