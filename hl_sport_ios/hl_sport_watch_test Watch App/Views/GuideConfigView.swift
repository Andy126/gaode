//
//  GuideConfigView.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/8.
//

import SwiftUI

struct GuideConfigView: View {
    //收发消息会话
    @EnvironmentObject var sessionMg: SessionManager
    
    var body: some View {
        VStack(alignment: .leading, content: {
            Image("icon_noconfig")
            Text("Holosport")
                .font(.system(size: 30))
                .fontWeight(.semibold)
                .offset(y: 8)
//            Text(network.netstatus)
            Text("settings_in_iphone".localized)
                .font(.system(size: 18))
                .offset(y: 11)
//            if sessionMg.isReceive {
//                Text(sessionMg.receiveData?.toStr() ?? "")
//            }
        })
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(EdgeInsets(top: 0, leading: 9, bottom: 10, trailing: 8))
        .background(Image("iwatch_bg"))
        .onAppear(perform: {
            //监听锁屏
//            SpringboardNotify().lockStateChanged()
            
//            WKInterfaceDevice.current().play(WKHapticType.stop)
            //查询绑定信息
//            sessionMg.getDeviceInfo()
//            sessionMg.configureWCSession()
            if !sessionMg.isReceive {
                Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
                    if sessionMg.isReceive {
                        timer.invalidate()
                    } else {
                        sessionMg.getDeviceInfo()
                    }
                }
            }
        })
//        .task(id: sessionMg.isReceive) {
//            UserDefaults.standard.setValue(true, forKey: "HL_PhoneConfigured")
//        }
    }
}

#Preview {

    GuideConfigView()
}
