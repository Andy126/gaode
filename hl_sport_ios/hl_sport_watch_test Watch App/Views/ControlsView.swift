//
//  ControlsView.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/1.
//

import SwiftUI

struct ControlsView: View {
    
    @EnvironmentObject var wtManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    
    @State var disabled = false
//    @State var showAlert = false
    
    var body: some View {
        VStack {
            HStack {
//                Rectangle()//矩形
//                    .fill(Color(uiColor: UIColor(hexString: "#690202")))
//                    .frame(width: 128, height: 48)
//                    .cornerRadius(24)
//                    .overlay {
//                    }
                Button {
                } label: {
                    NavigationLink(isActive: $disabled) {
                        EndAlertView()
                            .environmentObject(wtManager)
                            .navigationBarBackButtonHidden(false)
                    } label: {
                        Image("icon_end")
                        .onTapGesture {
//                            showAlert = true
                            print("tap end")
                            disabled = true
                        }
                        .gesture(DragGesture().onChanged({ value in
                            print(value.location)
                            disabled = false
                        }))
                    }
                    .frame(width: 30, height: 30)
                    .cornerRadius(1)
//                    .border(Color(red: 114/255.0, green: 42/255.0, blue: 40/255.0).opacity(0.6), width: 1)
                    .background(Color(uiColor: UIColor(hexString: "#690202")))
                }
//                .disabled(false)
                .background(Color(uiColor: UIColor(hexString: "#690202")))
                .frame(width: 128, height: 48)
                .cornerRadius(24)
            }
            
            HStack {
                Button {
                } label: {
                    Image(wtManager.running ? "icon_pause" : "icon_play")
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            wtManager.togglePause()
                        }
                }
                .background(Color(uiColor: UIColor(hexString: "#225203")))
                .frame(width: 128, height: 48)
                .cornerRadius(24)
            }
            .offset(y: 16)
        }
        .padding(EdgeInsets(top: 8, leading: 30, bottom: 0, trailing: 30))
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
//        .alert(isPresented: $showAlert) {
//            Alert(title: Text("save_swimming_data".localized), message: nil, primaryButton:
//                    .default(Text("confirm".localized), action: {
//                    }), secondaryButton: .destructive(Text("delete".localized), action: {
//                        showAlert = false
//                    }))
//        }.navigationBarBackButtonHidden(false)
    }
    
    private func postnoti() {
//        delegate?.controlEvent()
//        NotificationCenter.default.post(name: NSNotification.Name("showMetricsView"), object: nil)
    }
}

struct ControlsView_Previews: PreviewProvider {
    static var previews: some View {
        ControlsView().environmentObject(WorkoutManager.shared)
    }
}
