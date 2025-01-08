//
//  SessionPagingView.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/1.
//

import SwiftUI
//import WatchKit
//import HealthKitUI

struct SessionPagingView: View {

    @EnvironmentObject var wtManager: WorkoutManager
    //是否夜间模式
    @Environment(\.isLuminanceReduced) var isLuminance
    @Environment(\.dismiss) var dismiss

    @State private var selection: Tab = .metrics
    
    enum Tab {
    
        case metrics, controls
    }
    
    var body: some View {
//        if #available(watchOS 10.0, *) {
        ZStack {
            TabView(selection: $selection,
                    content:  {
                
                MetricsView().tag(Tab.metrics)
                ControlsView().tag(Tab.controls)
            })
            //            .navigationTitle("")
//            .navigationBarBackButtonHidden(true)
            //            .task(id: isLuminance, {
            //                showMetricsView()
            //            })
            .task(id: wtManager.running, {
                //暂停/继续
                showMetricsView()
            })
            .toolbar {
                if !wtManager.btManger.isConnect {
                    //断连图标
                    if #available(watchOS 10.0, *) {
                        ToolbarItem(placement: .topBarLeading) {
                            Image("icon_duankai_24px_iw")
                        }
                    } else {
                        // Fallback on earlier versions
                        ToolbarItem(placement: .automatic) {
                            Image("icon_duankai_24px_iw")
                        }
                    }
                }
            }
            .onAppear(perform: {
                if wtManager.showHome {
                    dismiss()
                }
            })
            .task(id: wtManager.showHome) {
                if wtManager.showHome {
                    dismiss()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: isLuminance ? .never : .automatic))
        }
        .edgesIgnoringSafeArea(.bottom) // 确保 TabView 能够延伸到屏幕底部
    }
    
    func showMetricsView() {
        withAnimation {
            selection = .metrics
        }
    }
}

#Preview {
    SessionPagingView().environmentObject(WorkoutManager.shared)
}
