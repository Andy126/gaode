//
//  ContentView.swift
//  LPHolosportWatch Watch App
//
//  Created by gl on 2024/3/27.
//

import SwiftUI

struct ContentView: View {
        
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: "globe")
                .imageScale(.large)
                .aspectRatio(contentMode: .fill)
                .foregroundStyle(.tint)
                .frame(width: 36, height: 36)
            Text("Holosport")
                .font(.system(size: 36))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
//            Spacer()
            Text("请在手机端app中完成设置。")
                .font(.system(size: 24, design: .monospaced))
                .fontWeight(.regular)
                .lineLimit(2)
                .frame(height: 60)
        }
        .padding(EdgeInsets(top: 10, leading: 8, bottom: 10, trailing: 8))
//        .onAppear(perform: {
//            //网络请求返回数据并解析
//            NetworkManager().fetchData { data in
//                print(data)
//            }
//        })
    }
}

#Preview {
    ContentView()
}
