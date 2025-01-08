//
//  PromptView.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/9.
//

import SwiftUI

struct PromptView: View {
    @EnvironmentObject var wtManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        
        VStack(content: {
            ScrollView {
                itemView(text: "unlock_screen_swimming".localized)
//                itemView(text: "pause_or_continue".localized)
                itemView(text: "weak_GPS_signal".localized)
            }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
            
            NavigationLink {
                
                DeviceInfoView()
                    .navigationViewStyle(StackNavigationViewStyle())
                    .navigationBarBackButtonHidden(false)
            } label: {
                Text("confirm".localized)
                    .font(.system(size: 25, weight: .semibold))
                    .colorMultiply(Color(uiColor: UIColor(hexString: "#333333")))
            }
//            .animation(nil)
            .background(Color(uiColor: UIColor(hexString: "#64FF00")))
            .cornerRadius(30)
            .frame(maxWidth: .infinity, minHeight: 32)
            .padding(EdgeInsets(top: 6, leading: 8, bottom: -20, trailing: 8))
        })
        .background(Image("iwatch_bg"))
        .onAppear(perform: {
            if !wtManager.showHome {
                wtManager.showRecord = false
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
    PromptView().environmentObject(WorkoutManager.shared)
    
}

struct itemView: View {
    var text: String
    @State private var transitionX = 4
    @State private var shouldAnimate = false

    var body: some View {

        HStack(content: {
            Circle()
                .frame(width: 4, height: 4)
                .colorMultiply(Color(uiColor: UIColor(hexString: "#64FF00")))
//                .offset(x: 0,y: 0)
            Text(text)
                .font(.system(size: 17))
                .offset(x: 5, y: 0)
            // 白色矩形，只有左上角和左下角有圆角
//            Rectangle()
//                .fill(Color.white)
//                .frame(width: 20, height: 30)
//                .cornerRadius(4)
//                .overlay(
//                    // 箭头图标
//                    Image("icon_anxia")
//                )
//                .animation(.linear(duration: 1), value: shouldAnimate)
//                .transition(AnyTransition.slide)
//                .offset(x: CGFloat(transitionX))

        })
        .frame(maxWidth: .infinity, alignment: .leading)
//        .onAppear(perform: {
//            withAnimation(.linear(duration: 1.5)) {
//                transitionX += 11
//            }
            
//            shouldAnimate = true
//            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
//                shouldAnimate = false
//            }
//        })
    }
}
