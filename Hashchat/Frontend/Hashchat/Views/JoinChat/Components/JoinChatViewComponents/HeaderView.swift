//
//  HeaderView.swift
//  Hashchat
//
//  Created by Enes Eken 2 on 21.10.2025.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image("Hashchat")
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 3)

            Text("HashChat")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(colors: [.cyan.opacity(0.8), .blue], startPoint: .top, endPoint: .bottom)
                )
        }
    }
}

#Preview {
    HeaderView()
}
