//
//  Device InfoView.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/9.
//

import SwiftUI
import Foundation
import HealthKit

struct DeviceInfoView: View {
    @EnvironmentObject var wtManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    //蓝牙管理器
    @StateObject private var btManger = BluetoothManager.shared
    //收发消息会话
//    @StateObject private var sessionMg = SessionManager.shared
//    @Binding var isShowing: Bool
//    @State var isConnect = false
//    @State private var counter = 0
//    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, content: {
            Text("Holosport")
                .font(.system(size: 23))
                .fontWeight(.semibold)
            
            Text("turn_on_goggles".localized)
//            Text(btManger.statestr)
                .font(.system(size: 13))
                .lineLimit(3)
//                .offset(y: 1)
                .frame(height: 47)
            
            HStack(content: {
                VStack(alignment: .leading, content: {
                    HStack(spacing: 6, content: {
                        Image("icon_shebei_24px_iw")
                        Spacer()
                        Image(btManger.isConnect ? "icon_ilianjie_24px_iw" : "icon_weilianjie_24px_iw")
                    })
                })
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                Divider()
                
                if #available(watchOS 10.5, *) {
                    VStack(alignment: .trailing, content: {
                        HStack(spacing: 6, content: {
                            Image("icon_gps_24px_iw")
                            Spacer()
                            Image(wtManager.cllAccuracy>0 ? (wtManager.cllAccuracy>30 ? "icon_xinhaoruo_24px_iw" : "icon_xinhaohao_24px_iw") : "icon_wuxinhao_24px_iw")
                        })
                    })
                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                } else {
                    VStack(alignment: .trailing, content: {
                        HStack(spacing: 6, content: {
                            Image("icon_gps_24px_iw")
                            Spacer()
                            Image(wtManager.cllAccuracy>0 ? (wtManager.cllAccuracy>30 ? "icon_xinhaoruo_24px_iw" : "icon_xinhaohao_24px_iw") : "icon_wuxinhao_24px_iw")
                        })
                    })
                }
            })
            .background(Color(uiColor: UIColor(hexString: "#333333")))
            .frame(maxWidth: .infinity, minHeight: 32, alignment: .leading)
            .cornerRadius(8)
            .overlay(content: {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color(uiColor: UIColor(hexString: "#666666")), lineWidth: 1.0)
            })
            
            if btManger.isConnect {
                NavigationLink(tag: HKWorkoutActivityType.swimming, selection: $wtManager.selectedWorkout) {
                    SessionPagingView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Text("start".localized)
                        .font(.system(size: 25, weight: .semibold))
                        .colorMultiply(Color(uiColor: UIColor(hexString: "#333333")))
                        .frame(maxWidth: .infinity, minHeight: 32)
                }
                //                .animation(nil)
                .background(Color(uiColor: UIColor(hexString: "#64FF00")))
                .cornerRadius(30)
                .offset(y: 1)
                .padding(EdgeInsets(top: 5, leading: 8, bottom: -10, trailing: 8))
            } else {
                //连接中
                ProgressView("connecting".localized)
            }
        })
        .background(Image("iwatch_bg"))
        .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
        .onAppear(perform: {
            if !wtManager.showHome {
                wtManager.showRecord = false
                //健康授权
                wtManager.requestAuthorization()
                //定位
                wtManager.initCLL()
                //蓝牙初始化
                btManger.isConnect = false
                btManger.initCenterManager()
                Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { timer in
                    if btManger.isConnect {
                        timer.invalidate()
                    } else {
                        btManger.scanForPeripheral()
                    }
                }
                
                //查询单位
                DispatchQueue.global(qos: .background).async {
                    wtManager.getMeasureUnit()
                }
                //关闭游泳提示
                UserDefaults.setInfo(true, forKey: "HSPrompted")
            } else {
                dismiss()
            }
        })
        .onDisappear(perform: {
            //停止蓝牙扫描
            btManger.stopScan()
        })
        .task(id: btManger.isConnect, {
            if btManger.isConnect {
                btManger.showConnect = true
            } else {
                //断开后扫描
                btManger.scanForPeripheral()
            }
        })
        .task(id: wtManager.showHome, {
            if wtManager.showHome {
                dismiss()
            }
        })
    }
}

#Preview {
    DeviceInfoView()
}
