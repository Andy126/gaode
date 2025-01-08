//
//  RemindView.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/4/9.
//

import SwiftUI

struct RemindView: View {
    var isSync: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, content: {
            Text("Holosport")
                .font(.system(size: 30, weight: .semibold))
                .offset(x: 8, y: 5)
//                .frame(maxWidth: .infinity, alignment: .leading)
            Text(isSync ? "records_synchronized".localized : "no_unsynchronized_data".localized)
                .font(.system(size: 15))
                .padding(EdgeInsets(top: 6, leading: 8, bottom: 0, trailing: 8))
                .frame(maxWidth: .infinity, minHeight: 50)

            Image(isSync ? "img_iwip_100px" : "icon_empty")
                .frame(maxWidth: .infinity, alignment: .center)
                .offset(y: 8)
        })
        .background(Image("iwatch_bg"))
    }
}

#Preview {
    RemindView().environmentObject(WorkoutManager.shared)
}
