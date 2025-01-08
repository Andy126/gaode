//
//  ResultView.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/8.
//

import SwiftUI

struct RecordView: View {
    @EnvironmentObject var wtManager: WorkoutManager
    @State private var durationFormatter: DateComponentsFormatter = {
        let fm = DateComponentsFormatter()
        fm.allowedUnits = [.hour, .minute, .second]
        fm.zeroFormattingBehavior = .pad
        return fm
    }()
    
    @State private var hmFormatter: DateFormatter = {
        let fm = DateFormatter()
        fm.dateFormat = "HH:mm"
        return fm
    }()
    
    var body: some View {
        
        TabView {
            if wtManager.showCache && wtManager.cacheData.count>0 {
                ForEach(wtManager.cacheData, id: \.self) { item in
                    let speed = item.detailList?.last?.pace ?? 0
                    let lenUnit = (item.lengthUnit == 1 ? "m" : "yd")
                    ResultView(
//                        time: "\(item.endTime.split(separator: " ").last ?? "")",
//                        time: hmFormatter.string(from: Double(item.endTimestamp)) ?? "",
                        time: hmFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(item.endTimestamp))),
                        duration: durationFormatter.string(from: Double(item.totalDurationTime)) ?? "",
                        consume: "\(Int(item.totalCalorie)) Kcal",
                        heartRate: "\(item.averageHeartRate) \("times_per_minute".localized)",
                        distance: "\(Int(item.totalDistance)) \(lenUnit.localized)",
                        pace: "\(speed/60)‘\(speed%60)‘’",
                        pace100: "100_\(lenUnit)_pace".localized)
                }
            } else {
                RemindView(isSync: UserDefaults.standard.bool(forKey: "Holo_SyncMotionData"))
            }
        }
        .tabViewStyle(.carousel)
//        .navigationTitle("结果")
//        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            //有缓存时上传数据
//            if wtManager.showCache {
//            wtManager.syncSwimData()
//            }
            //上传缓存数据
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                wtManager.syncSwimData()
            }
        }
    }
}

#Preview {
    RecordView()

//    RecordView().environmentObject(WorkoutManager.shared)
}

//未上传的运动记录
struct ResultView: View {
    //时间
    var time: String = "19:41"
    //时长
    var duration: String = "12:10:01"
    //消耗卡路里
    var consume: String = "431 Kcal"
    //心率
    var heartRate: String = "123次 / 分"
    //距离
    var distance: String = "3200 米"
    //百米配速
    var pace: String = "01‘03‘’"
    var pace100: String = "百米配速"

    var body: some View {
        VStack{
            HStack(content: {
                Text("\(time) \("swimming_record".localized)")
                    .font(.system(size: 10))
                    .frame(maxWidth: .infinity, alignment: .leading)
            })
            .offset(x: 8, y: 0)
            
            HStack(content: {
                VStack(alignment: .leading, content: {
                    ResultTitleView(title: "duration".localized)
                    ResultTitleView(title: "consume".localized)
                    ResultTitleView(title: "heart_rate".localized)
                    ResultTitleView(title: "distance".localized)
                    ResultTitleView(title: pace100)
                })
                .font(.system(size: 10))
                .colorMultiply(Color(uiColor: UIColor(hexString: "#999999")))
                .frame(maxWidth: 90, alignment: .leading)
                
                VStack(content: {
                    ResultValView(title: duration)
                        .foregroundColor(Color(uiColor: UIColor(hexString: "#64FF00")))
                    ResultValView(title: consume)
                    ResultValView(title: heartRate)
                        .colorMultiply(.red)
                    ResultValView(title: distance)
                    ResultValView(title: pace)
                })
                .font(.system(size: 14, weight: .semibold))
                .frame(maxWidth: 120, alignment: .trailing)
                //70
            })
            .offset(y: 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        //        .background(RoundedRectangle(cornerRadius: 10).fill(Color(uiColor: UIColor(hexString: "#333333")))
        //            .clipShape(RoundedRectangle(cornerRadius: 10)))
        .background(Color(uiColor: UIColor(hexString: "#333333")))
        .cornerRadius(10)
        .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
    }
}

struct ResultTitleView: View {
    var title: String
    
    var body: some View {
        Text(title)
            .frame(height: 16)
            .padding(EdgeInsets(top: 2, leading: 8, bottom: 0, trailing: 0))
    }
}

struct ResultValView: View {
    var title: String
    
    var body: some View {
        Text(title)
            .frame(height: 16)
            .padding(EdgeInsets(top: 2, leading: 0, bottom: 0, trailing: 8))
    }
}
