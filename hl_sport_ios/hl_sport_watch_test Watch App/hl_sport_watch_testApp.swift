//
//  hl_sport_watch_testApp.swift
//  hl_sport_watch_test Watch App
//
//  Created by gl on 2024/4/19.
//

import SwiftUI

@main
struct hl_sport_watch_test_Watch_AppApp: App {
//    @WKApplicationDelegateAdaptor(AppDelegate.self) var delegate

    //收发消息会话
    @StateObject private var sessionMg = SessionManager.shared

    var body: some Scene {
        WindowGroup {
//            NavigationView
            let configured = UserDefaults.standard.value(forKey: "HL_PhoneConfigured") as? Bool ?? false
            if configured || sessionMg.isReceive {
                HomeView()
                    .navigationBarBackButtonHidden(false)
//                    .navigationViewStyle(StackNavigationViewStyle())
//                    .navigationBarTitleDisplayMode(.automatic)
//                    .navigationTitle("首页")
            } else {
                //引导设置
                GuideConfigView()
                    .environmentObject(sessionMg)
            }
        }
    }
}
