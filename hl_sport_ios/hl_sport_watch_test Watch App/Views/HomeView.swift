//
//  HomeView.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/2.
//

import SwiftUI

struct HomeView: View {
    @State var selection: Tab = .start
    @StateObject private var wtManager = WorkoutManager.shared
    @State private var showrecord = true
    @Environment(\.scenePhase) var scenePhase
    
    @State var showlogdata: [Any]?
    
    enum Tab {
        case start, record
    }
    
    
    var body: some View {
        
        TabView(selection: $selection,
                content:          {
            //            Text(network.netstatus)
            StartView().tag(Tab.start)
            if showrecord {
                RecordView().tag(Tab.record)
            }
//            //log页面
//            ScrollView {
//                Text( BluetoothManager.shared.logStr)
//                    .onTapGesture {
//                        selection = .start
//                    }
//            }
//            .onLongPressGesture(minimumDuration: 1, maximumDistance: 1, perform: {
//            })
//            .onAppear {
//            }
        }
        )
        
        //        TabView(selection: $selection,
        //                content:  {
        ////            Text(network.netstatus)
        //            StartView().tag(Tab.start)
        //            if showrecord {
        //                RecordView().tag(Tab.record)
        //            }
        //        })
        .environmentObject(wtManager)
        .tabViewStyle(.page(indexDisplayMode: (showrecord ? .automatic : .never)))
        //        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
        .navigationBarBackButtonHidden(false)
        .navigationViewStyle(StackNavigationViewStyle())
        .task(id: wtManager.showRecord) {
            //            if selection == .record {
            showrecord = wtManager.showRecord
            //            }
        }
        .onAppear {
            //            wtManager.showRecord = true
            showrecord = true
            //停止定位
            wtManager.stopLocation()
            //停止蓝牙扫描
            wtManager.btManger.stopScan()
            wtManager.btManger.scanning = true
            //上传缓存数据
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                wtManager.syncSwimData()
            }
            print("首页显示")
        }
        .sheet(isPresented: $wtManager.showingSummaryView, content: {
            SumupView()
                .environmentObject(wtManager)
                .navigationBarBackButtonHidden(true)
            //                            .blur(radius: 0, opaque: true)
        }).task(id: scenePhase) {
            switch scenePhase {
            case .active:
                //上传缓存数据
                DispatchQueue.main.asyncAfter(deadline: .now()+1.2) {
                    WorkoutManager.shared.syncSwimData()
                }
                print("进入前台")
            case .background:
                print("进入后台")
            case .inactive:
                print("不活跃")
            default:
                print("defa")
            }
        }
        
        
    }
}
extension [Any] {
    func tojson() -> String {
        let string = self.map { String(describing: $0) }.joined(separator: "\n")
        return string
    }
}

extension [String: Any] {
    //字典转字符串
    func toStr() -> String{
        var str = ""
        self.forEach { (key: String, value: Any) in
            str.append("\(key):\(value) ")
        }
        return str
    }
}

struct StartView: View {
    @EnvironmentObject var wtManager: WorkoutManager
    
    var body: some View {
        //        GeometryReader { geometryProxy in
        //            // geometryProxy.size.width 将给你当前视图的宽度
        //            Text("\(WKInterfaceDevice.current().screenBounds.width)")
        //            Text("Screen width: \(geometryProxy.size.width)")
        //        }
        
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Holosport")
                        .font(.system(size: 30))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .offset(x: 10)
                }
                //                Spacer()
                //                Button {
                //                NavigationLink(tag: false, selection: $wtManager.showHome) {
                NavigationLink {
                    let showPrompted = UserDefaults.standard.bool(forKey: "HSPrompted")
                    if showPrompted {
                        DeviceInfoView()
                            .navigationBarBackButtonHidden(false)
                            .navigationViewStyle(StackNavigationViewStyle())
                    } else {
                        PromptView()
                    }
                } label: {
                    VStack(alignment: .leading, content: {
                        HStack(content: {
                            Image("open_water_icon")
                                .font(.title2)
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 0))
                            //                                .multilineTextAlignment(.leading).offset(x: 5.0)
                            Spacer()
                            Image("more")
                                .font(.title2)
                                .padding(EdgeInsets(top: 10, leading: 0, bottom: 5, trailing: 10))
                        })
                        //                        Text(wtManager.devName)
                        Spacer()
                        Text("open_water_swim".localized)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 51/255, green: 51/255, blue: 51/255))
                            .frame(width: .infinity, height: 40)
                            .lineLimit(2)
                        //                            .multilineTextAlignment(.center)
                            .padding(EdgeInsets(top: 0, leading: 10, bottom: 35, trailing: 5))
                        //                            .multilineTextAlignment(.leading).offset(x: 5.0)
                    })
                    .background(Color(red: 100/255, green: 255/255, blue: 0))
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                }
                //                .animation(nil)
                .padding(EdgeInsets(top: 21, leading: 0, bottom: 10, trailing: 0))
            }
            .background(Image("iwatch_bg"))
            .onAppear {
                wtManager.showHome = false
                wtManager.showRecord = true
                //健康授权
                wtManager.requestAuthorization()
                //停止定位
                wtManager.stopLocation()
                //停止蓝牙扫描
                wtManager.btManger.stopScan()
                wtManager.btManger.scanning = true
                //提示音
                //                WKInterfaceDevice.current().play(WKHapticType.notification)
            }
            .alert(isPresented: $wtManager.sharingDenied) {
                Alert(title: Text("permission_failed".localized), message: Text("please_settings".localized), primaryButton:
                        .default(Text("confirm".localized), action: {
                            //                    healthStoreManager.presentSettingsController()
                            //                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                            //                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                        }), secondaryButton: .cancel())
            }
            .onDisappear {
                //                workoutManager.showRecord = false
            }
            
        }
    }
}

#Preview {
    HomeView().environmentObject(WorkoutManager.shared)
}
