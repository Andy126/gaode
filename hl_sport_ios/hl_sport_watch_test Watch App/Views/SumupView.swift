//
//  SumupView.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/8.
//

import SwiftUI
import HealthKit

struct SumupView: View {
    @EnvironmentObject var wtManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    @State private var durationFormatter: DateComponentsFormatter = {
        let fm = DateComponentsFormatter()
        fm.allowedUnits = [.hour, .minute, .second]
        fm.zeroFormattingBehavior = .pad
        return fm
    }()
    @State private var hmFormatter: DateFormatter = {
        let fm = DateFormatter()
//        fm.dateFormat = "MM/dd"
        fm.dateFormat = "HH:mm"
        return fm
    }()
//    let onReturn: () -> Void
    @State private var showAlert = false
    @State private var speed100 = 0

    var body: some View {
//        if wtManager.workout == nil {
//        if wtManager.showProgress {
//            ProgressView("saving".localized)
//                .navigationBarHidden(true)
//        } else {
            ScrollView {
                VStack(alignment: .leading, content: {
                    
                    Text("\(hmFormatter.string(from: wtManager.workout?.endDate ?? Date())) \("swimming_record".localized)")
                        .font(.system(size: 18))
                    let duration = wtManager.workout?.duration ?? 0.0
                    Text("\("swimming_duration".localized) \(durationFormatter.string(from: duration) ?? "")")
                        .font(.system(size: 15))
                        .offset(y: 4)

                    let distUnit = wtManager.distanceUnit == "m" ? HKUnit.meter() : .yard()
                    let distance = wtManager.workout?.totalDistance?.doubleValue(for: distUnit) ?? 0
                    MetricView(img: "icon_juli_iw", title: "swimming_distance".localized, value: "\(Int(distance)) \(wtManager.distanceUnit.localized)")
                    let speed = Int(wtManager.speed) //rounded
//                        speed = Int((duration/distance*100.0).rounded())
                    MetricView(img: "icon_peisu_iw", title: "100_\(wtManager.distanceUnit)_pace".localized, value: "\(speed/60)‘\(speed%60)‘’")
                    let burned = wtManager.workout?.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
                    MetricView(img: "icon_xiaohao_iw", title: "consume".localized, value: "\(Int(burned)) Kcal")
//                    let heartRate = wtManager.averageHeartRate.formatted(.number.precision(.fractionLength(0)))
                    let heartRate = wtManager.averageHeartRate.rounded()
                    MetricView(img: "icon_xinlv_iw", title: "average_heart_rate".localized, value: "\(Int(heartRate)) \("times_per_minute".localized)")
//                    ActivityRingsView(healthStore: wtManager.healthStore)
                })
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    dismiss()
                    wtManager.showRecord = true
                }, label: {
                    Text("confirm".localized)
                        .font(.system(size: 28, weight: .semibold))
                        .colorMultiply(Color(uiColor: UIColor(hexString: "#333333")))
                })
                .background(Color(uiColor: UIColor(hexString: "#64FF00")))
                .cornerRadius(32)
    //            .frame(maxWidth: .infinity, minHeight: 32)
                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            }.background(Image("iwatch_bg"))
            .navigationTitle("")
            .background(.black)
    }
}

//#Preview {
//    SumupView().environmentObject(WorkoutManager.shared)
//}

struct MetricView: View {
    var img: String
    var title: String
    var value: String

    var body: some View {
        HStack(content: {
            Image(img)
                .offset(x: 5, y: 0)
                .padding(.leading)
                .frame(width: 24, height: 24)
            VStack(alignment: .leading, content: {
                Text(title)
                    .colorMultiply(Color(uiColor: UIColor(hexString: "#999999")))
                    .font(.system(size: 10))
                Text(value)
                    .font(.system(size: 12, weight: .semibold))
                    .offset(y: 1)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: 10, y: 0)
            
        })
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(Color(uiColor: UIColor(hexString: "#333333")))
        .cornerRadius(10)
        .offset(y: 4)
    }
}
