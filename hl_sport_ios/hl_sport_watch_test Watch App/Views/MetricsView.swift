/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The workout metrics view.
*/

import SwiftUI
import HealthKit
import WatchKit
import SpriteKit

struct MetricsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    //生命周期
//    @Environment(\.scenePhase) var scenePhase
//    @State var phase = "-"
//    @StateObject var springboard = SpringboardNotify()
//    @State var scrollAmount: Float = 0.0

    let H = WKInterfaceDevice.current().screenBounds.height
//    let fontsize = 24/156.0 * W
//    let skScene = SKScene(size: CGSize(width: 30, height: 30))
    
    var body: some View {
//        Text(phase)
//        SpriteView(scene: skScene)
//            .focusable(true)
//            .digitalCrownRotation($scrollAmount, from: -70, through: 70, by: 0.1, sensitivity: .high, isContinuous: false, isHapticFeedbackEnabled: false)
//            .onChange(of: scrollAmount) { newValue in
//                scrollAmount = newValue
//            }
//            .onTapGesture {
//                dismiss()
//            }
        
        TimelineView(MetricsTimelineSchedule(from: workoutManager.builder?.startDate ?? Date(), isPaused: workoutManager.session?.state == .paused)) { context in
            VStack(alignment: .leading,spacing: 4) {
                if !workoutManager.btManger.showConnect {
                    //断连图标
                    if #unavailable(watchOS 10.0) {
                        //45mm:198,242   44mm:184,224   40mm:162,197   41mm:176,215
                        Image("icon_duankai_24px_iw")
//                            .frame(width: .infinity, height: 30)
                            .offset(y: H==215 ? 20 : 17).padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))

                    }
                }
                if workoutManager.cTrol == 3 {
                    Text("paused".localized)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(uiColor: UIColor(hexString: "#FE1616")))
                        .frame(width: .infinity, height: (H<220 ? 20 : 12))
                        .offset(y: 10)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))

                }
                //时间
                HStack(content: {
                    ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime(at: context.date) ?? 0, showSubseconds: context.cadence == .live)
                        .foregroundColor(Color(red: 100/255, green: 255/255, blue: 0))
                        .frame(width: 110, alignment: .leading)
                    Image("icon_youyongjuli_16px")
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                })

//                if #unavailable(watchOS 10.0) {
//                    .offset(y: 3)
//                }
//                Text(phase)

                //千卡
//                Text(Measurement(value: workoutManager.activeEnergy, unit: UnitEnergy.kilocalories)
//                        .formatted(.measurement(width: .abbreviated, usage: .workout, numberFormatStyle: .number.precision(.fractionLength(0)))))
                HStack(content: {
//                    Text(String(format: "%ld", workoutManager.activeEnergy))
//                    Text(workoutManager.activeEnergy.formatted(.number.precision(.fractionLength(0))))
                    Text("\(Int(workoutManager.activeEnergy))")
                        .font(.system(size: 24, weight: .medium))
                    VStack(content: {
                        Text("consume".localized)
                            .font(.system(size: 8))
                            .foregroundColor(.gray)
//                            .frame(maxWidth: .infinity, maxHeight: 12, alignment: .leading)
//                        Spacer()
                        Text("Kcal").font(.system(size: 8))
//                            .frame(maxWidth: .infinity, maxHeight: 12, alignment: .leading)
                    }).padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                })

                
                //心率
                HStack(content: {
//                    Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))))
                    Text("\(Int(workoutManager.heartRate))")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color(uiColor: UIColor(hexString: "#FE1616"))).padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    VStack(content: {
                        Image("icon_ht_10px")
                         .frame(width: 10, height: 8)
                         .padding(EdgeInsets(top: 0, leading: -14, bottom: 0, trailing: 0))
                        Text("times_per_minute".localized)
                            .font(.system(size: 10))
                    })
                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                })
                
                //距离
//                Text(Measurement(value: workoutManager.distance, unit: UnitLength.meters).formatted(.measurement(width: .abbreviated, usage: .road)))
                HStack(content: {
//                    Text(workoutManager.distance.formatted(.number.precision(.fractionLength(0))))//四舍五入
                    Text("\(Int(workoutManager.distance))")
                        .font(.system(size: 24, weight: .medium))
                    VStack(content: {
                        Text("distance".localized)
                            .font(.system(size: 8))
                            .foregroundColor(Color(red: 153/255, green: 153/255, blue: 153/255))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(workoutManager.distanceUnit.localized).font(.system(size: 10))
                            .frame(maxWidth: .infinity, alignment: .leading)
//                        Text("\(workoutManager.longitude)")
                    })
                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                })
                
                //配速
//                Text(Measurement(value: workoutManager.speed, unit: UnitLength.hectometers).formatted())
                HStack(content: {
                    //rounded()
                    let speed = Int(workoutManager.speed)
                    Text("\(speed/60)‘\(speed % 60)‘’")
//                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(Color(uiColor: UIColor(hexString: "#12E8E0")))
//                        .frame(minWidth: 56)
                    VStack(content: {
                        Text("speed".localized)
                            .font(.system(size: 8))
                            .foregroundColor(Color(red: 153/255, green: 153/255, blue: 153/255))
                        Text("/ 100\(workoutManager.distanceUnit)").font(.system(size: 10))
//                            .frame(maxWidth: .infinity, alignment: .leading)
                    })
                    .padding(EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                })
            }.padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
            .font(.system(size: 24))
//            .font(.system(.title, design: .rounded).monospacedDigit().lowercaseSmallCaps())
            .frame(maxWidth: .infinity, alignment: .leading)
//            .frame(alignment: .leading)
            .ignoresSafeArea(edges: .bottom)
            .scenePadding()
            .background(Image("iwatch_bg"))
            .task(id: workoutManager.showHome) {
                if workoutManager.showHome {
                    dismiss()
                }
            }
//            .task(id: scenePhase) {
//                switch scenePhase {
//                case .active:
//                    self.phase = "active"
////                    workoutManager.togglePause()
//                    print("进入前台")
//                case .background:
//                    self.phase = "back"
//                    print("进入后台")
//                case .inactive:
//                    self.phase = "inactive"
//                    print("不活跃")
//                default:
//                    self.phase = "defa"
//                    print("defa")
//                }
//            }
            .onAppear {
                //监听锁屏
//                springboard.lockStateChanged {}
                if workoutManager.showHome {
                    dismiss()
                }
            }
        }
    }
}

struct MetricsView_Previews: PreviewProvider {
    static var previews: some View {
        MetricsView().environmentObject(WorkoutManager.shared)
    }
}

private struct MetricsTimelineSchedule: TimelineSchedule {
    var startDate: Date
    var isPaused: Bool

    init(from startDate: Date, isPaused: Bool) {
        self.startDate = startDate
        self.isPaused = isPaused
    }

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
        var baseSchedule = PeriodicTimelineSchedule(from: self.startDate, by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0))
            .entries(from: startDate, mode: mode)
        
        return AnyIterator<Date> {
            guard !isPaused else { return nil }
            return baseSchedule.next()
        }
    }
}
