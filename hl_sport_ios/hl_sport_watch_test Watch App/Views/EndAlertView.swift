//
//  EndAlertView.swift
//  hl_sport_watch_test Watch App
//
//  Created by gl on 2024/5/20.
//

import SwiftUI

struct EndAlertView: View {
    @EnvironmentObject var wtManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    @State var showProgress = false
    @State var showSaving = false

    var body: some View {
        
        if showSaving {
            ProgressView("saving".localized)
                .task(id: wtManager.showHome) {
                    if wtManager.showHome {
                        dismiss()
                    }
                }
                .onAppear {
                    if wtManager.showHome {
                        dismiss()
                    }
                }
        } else {
            HStack(alignment: .top, content: {
                Text("save_swimming_data".localized)
    //                .offset(x:-8)
            })
            .font(.system(size: 18, weight: .semibold))
            .frame(maxWidth: .infinity, alignment: .topLeading)
    //            .frame(height: 20)
            .padding(EdgeInsets(top: 28, leading: 8, bottom: 10, trailing: 0))
    //        Spacer()
          
            if showProgress {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            }
            Button(action: {
                //防止多次点击
                if showProgress == true{return}
                print("点击保存")
                showProgress = true
                DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                    wtManager.endWorkout()
                    withAnimation {
                        showProgress = false
                    }
                }
            }, label: {
                Text("confirm".localized)
                    .font(.system(size: 23, weight: .semibold))
                    .colorMultiply(Color(uiColor: UIColor(hexString: "#64FF00")))
            })
            .background(Color(uiColor: UIColor(hexString: "#225203")))
            .cornerRadius(32)
    //        .frame(maxWidth: .infinity, minHeight: 32)
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
            
            Button(action: {
                
                //防止多次点击
                if showProgress == true{return}
                
                //点击删除
                showProgress = true
                DispatchQueue.main.asyncAfter(deadline: .now()+1.5) {
                    wtManager.delWorkout()
                    dismiss()
                    withAnimation {
                        showProgress = false
                    }
                }
            }, label: {
                Text("delete".localized)
                    .font(.system(size: 23, weight: .semibold))
                    .colorMultiply(Color(uiColor: UIColor(hexString: "#FE1616")))
            })
            .background(Color(uiColor: UIColor(hexString: "#690202")))
            .cornerRadius(32)
    //        .frame(maxWidth: .infinity, minHeight: 32)
            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            .onAppear(perform: {
                if wtManager.showHome {
                    dismiss()
                } else {
                    //暂停
                    wtManager.pause()
                }
            })
            .task(id: wtManager.showHome) {
                if wtManager.showHome {
                    dismiss()
                }
            }
            .task(id: wtManager.showProgress) {
                showSaving = wtManager.showProgress
            }
    //        if #available(watchOS 10.0, *) {
    //            .onChange(of: wtManager.showHome) {
    //                if wtManager.showHome {
    //                    dismiss()
    //                }
    //            }
    //        }
        }
    }
}

#Preview {
    EndAlertView()
}
