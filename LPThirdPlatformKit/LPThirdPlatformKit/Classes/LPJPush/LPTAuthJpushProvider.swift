//
//  LPTAuthStravaProvider.swift
//  Action
//
//  Created by gl on 2023/6/7.
//

import LPNetwork
import LPCommon

public class LPTAuthJpushProvider: NSObject{
    
//    var JPappKey = "fa83f74adabb723f30334946"

    
     enum LPBizType: String {
         /**
          * 朋友圈通知
          */
        case CIRCLE_NOTICE = "circle-notice"
         /**
          * 粉丝通知
          */
         case FOLLOWER_NOTICE    = "follower-notice"
         /**
          * 游泳纪录刷新
          */
         case SWIM_RECORD_REFRESH    = "swim-record-refresh"

    }

    
    public var JPappKey: String {
        switch LPTargetManager.target.targetType {
        case .product:
            return "8f49962d2574d7311dc765aa"
        case .test:
            return "fa83f74adabb723f30334946"
        default:
            break
        }
    }

    
    var callbackResult: ((_ resultStr: String) -> Void)?

    
    public static let lpPhsh = LPTAuthJpushProvider()
    
    public  var registrationID: String {
        get{
            return JPUSHService.registrationID()
        }
    }

    
    
    
    override init() {
        super.init()
    }
    
    
    deinit{
        debugPrint(">>🍀\(self) 释放🍀")
    }
}


// MARK:  SDK 初始化 公共 API
extension LPTAuthJpushProvider: LPTApplicationRepresentable {




    public func handleApplication(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {

        //注册极光推送
        registerJPush(launchOptions: launchOptions)

    }


    //注册远程通知
    public func handleApplication(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        JPUSHService.registerDeviceToken(deviceToken)
        debugPrint("极光注册成功：\(deviceToken)")

    }
    //注册远程通知失败
    public func handleApplication(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("极光注册失败\(error)")
    }



    public func handleUniversalLink(application: UIApplication,
                                    userActivity: Any,
                                    options: [AnyHashable : Any]? = nil) -> Bool{

        return true
    }


    func registerJPush(launchOptions:[UIApplication.LaunchOptionsKey: Any]?){
        //注册极光推送

        let entity = JPUSHRegisterEntity()
        entity.types = NSInteger(UNAuthorizationOptions.alert.rawValue) |
          NSInteger(UNAuthorizationOptions.sound.rawValue) |
          NSInteger(UNAuthorizationOptions.badge.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: entity, delegate: self)
        
        JPUSHService.setup(withOption: launchOptions, appKey: JPappKey, channel: "App Store", apsForProduction: false, advertisingIdentifier: nil)
        
        
        
//        [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
//
//        NSLog(@"resCode : %d,registrationID: %@",resCode,registrationID);
//
//        }];
        
    }


}


extension LPTAuthJpushProvider: JPUSHRegisterDelegate {
    public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification!) {
        print("极光1")
    }
    
    public func jpushNotificationAuthorization(_ status: JPAuthorizationStatus, withInfo info: [AnyHashable : Any]!) {
        print("极光2")
        print(info)


    }
    
    
    //    public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, openSettingsFor notification: UNNotification!) {
    //
    //    }
    //
    //    public func jpushNotificationAuthorization(_ status: JPAuthorizationStatus, withInfo info: [AnyHashable : Any]!) {
    //
    //    }
        
        

        
        @available(iOS 10.0, *)
        public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
//            print("极光3")

      //    let userInfo = response.notification.request.content.userInfo
      //    let request = response.notification.request // 收到推送的请求
      //    let content = request.content // 收到推送的消息内容
      //
      //    let badge = content.badge // 推送消息的角标
      //    let body = content.body   // 推送消息体
      //    let sound = content.sound // 推送消息的声音
      //    let subtitle = content.subtitle // 推送消息的副标题
      //    let title = content.title // 推送消息的标题

        }
        
        @available(iOS 10.0, *)
        public func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!,
                                     withCompletionHandler completionHandler: ((Int) -> Void)!) {
//            print("极光4")

          let userInfo = notification.request.content.userInfo
      //
//          let request = notification.request // 收到推送的请求
//          let content = request.content // 收到推送的消息内容
      //
      //    let badge = content.badge // 推送消息的角标
//          let body = content.body   // 推送消息体
      //    let sound = content.sound // 推送消息的声音
      //    let subtitle = content.subtitle // 推送消息的副标题
      //    let title = content.title // 推送消息的标题
            
  
//          let json =  userInfo.dicToJson()
//            print("bizType == \(userInfo["bizType"])")
//            print("content == \(userInfo["content"])")
//            print("contentType == \(userInfo["contentType"])")
            
            
            let  bizType = userInfo["bizType"] as? String

            if let bizType = bizType,
               bizType == LPBizType.SWIM_RECORD_REFRESH.rawValue{
                let  content111 = userInfo["content"] as? String
                let dic =  content111?.jsonToDictionary()
                let recordId = dic?["recordId"] as? Int
                //刷新首页
                NotificationCenter.default.post(name: Notification.Name(rawValue: LPCommonStaticObject.recordRefresh.rawValue), object: nil )
            }
            
       
//            print("contentDic == \(dic)")
//            print("recordId == \(recordId)")

          

        }
        
        func applicationWillResignActive(_ application: UIApplication) {
          
        }
        
        func applicationDidEnterBackground(_ application: UIApplication) {
          
        }
        
        func applicationWillEnterForeground(_ application: UIApplication) {
          application.applicationIconBadgeNumber = 0
          application.cancelAllLocalNotifications()
        }
        
        func applicationDidBecomeActive(_ application: UIApplication) {
          
        }
        
        func applicationWillTerminate(_ application: UIApplication) {
          
        }

        

}
